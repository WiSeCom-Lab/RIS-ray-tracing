%% Import the data

% This channel dataset is generated for an indoor factory environment with
% center frequency 60GHz by using ray tracing software Wireless Insite

% Import the BS-MS channels
Info_BM = readlines('./data/Info_BM.txt');

% Import the BS-RIS channel
Info_BR = readlines('./data/Info_BR.txt');

% Import the RIS-MS channel
Info_RM = readlines('./data/Info_RM.txt');

%% Extract user paths

Paths_BM = channel_import(Info_BM);
Paths_BR = channel_import(Info_BR);
Paths_RM = channel_import(Info_RM);

UE_count = length(Paths_BM);    % Number of users in the dataset

[L_BM, ~] = size(Paths_BM{1});  % L_BM: number of BS-MS paths
[L_BR, ~] = size(Paths_BR{1});  % L_BR: number of BS-RIS paths
[L_RM, ~] = size(Paths_RM{1});  % L_RM: number of RIS-MS paths

%% Example: Time domain SISO channel generation with ULA RIS

% RIS shifts are matched to the AoA and AoD of the LoS paths

% Parameters
N_list = [16, 64, 256, 1024];       % Different number of RIS elements
FFT_size = 1024;                    % FFT size
delta_f = 120e3;                    % Subcarrier spacing
CP_len = 0.59e-6;                   % Cyclic-prefix duration
roll_off = 0.2;                     % Roll-off for raised cosine pulse

Ts = 1/(delta_f*FFT_size);          % Sampling period
D = ceil(CP_len/Ts);                % Number of delay taps

% Create the composite channel in time domain
num_UE = 20;                        % We evaluate the first num_UE users
channels_BM = zeros(num_UE, length(N_list), D);     % BM channel
channels_BRM = zeros(num_UE, length(N_list), D);    % Cascade channel
for ue = 1:num_UE
    for n = 1:length(N_list)
        N = N_list(n);
        % Compute the BS-MS channel
        h_BM = zeros(D, 1);
        for l = 1:L_BM
            alpha = 10^((Paths_BM{ue}(l, 3)-30)/20)*exp(1j*Paths_BM{ue}(l, 1)/180*pi);
            tau = Paths_BM{ue}(l, 2);
            for d = 0:D-1
                h_BM(d+1) = h_BM(d+1) + alpha*Ts*RC_filter(d*Ts-tau, roll_off, Ts);
            end
        end
        channels_BM(ue, n, :) = h_BM;        
        % Compute the BS-RIS-MS channel in cascade form
        h_BRM = zeros(D, 1);
        phi = exp(-1j*pi*(cosd(Paths_BR{1}(1, 4))-cosd(Paths_RM{ue}(1, 6)))*(0:N-1));
        for l = 1:L_BR
            for l2 = 1:L_RM
                alpha = 10^((Paths_BR{1}(l, 3)-30)/20)*10^((Paths_RM{ue}(l, 3)-30)/20)* ...
                    exp(1j*(Paths_BR{1}(l, 1)+Paths_RM{ue}(l, 1))/180*pi);
                % Include the effect of the RIS in the channel gain
                alpha = alpha*exp(-1j*pi*cosd(Paths_RM{ue}(l, 6))*(0:N-1))*diag(phi)* ...
                    exp(-1j*pi*cosd(Paths_BR{1}(l, 4))*(0:N-1))';
                tau = Paths_BR{1}(l, 2) + Paths_RM{ue}(l, 2);
                for d = 0:D-1
                    h_BRM(d+1) = h_BRM(d+1) + alpha*Ts*RC_filter(d*Ts-tau, roll_off, Ts);
                end
            end
        end
        channels_BRM(ue, n, :) = h_BRM;
    end
end
channels = channels_BM + channels_BRM;              % Composite channel

%% Plot the spectral efficiency vs. RIS size

% Frequency domain channel
channels_OFDM = sqrt(1/FFT_size)*fft(channels, FFT_size, 3);

% SNR calculation
Pt_dBm = 30;                                        % Transmit power (dBm)
sigma2_dBm = -173.8 + 10*log10(delta_f*FFT_size);   % Noise variance (dBm)
SNR = 10^((Pt_dBm-sigma2_dBm)/10);

figure
plot(N_list, mean(mean(log2(1+SNR*abs(channels_OFDM).^2), 3), 1), LineWidth=1.25, Marker="x");
xlabel('Number of RIS elements');
ylabel('Spectral efficiency (bits/s/Hz)');
xlim([N_list(1) N_list(end)])
grid on

%% Raised cosine filter

function pt = RC_filter(t, beta, Ts)
    if t == Ts/(2*beta) || t == -Ts/(2*beta)
        pt = (pi/(4*Ts))*sinc(1/(2*beta));
    else
        pt = (1/Ts)*sinc(t/Ts)*(cos(pi*beta*t/Ts))/(1-(2*beta*t/Ts)^2);
    end
end