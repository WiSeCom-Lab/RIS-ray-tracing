function Paths = channel_import(Info)
    
    % This function imports the information related to channel paths
    %
    % Input: Info variable, which is imported from a .txt file
    % Output: Paths is a cell array with length equal to the number of users
    % Each cell element is a matrix with dimension [Number of paths x Number of parameters]
    % 
    % The parameters at each column are as follows:
    % i = 1: Phase of the channel gain [-180,180]
    % i = 2: Delay of the paths (s)
    % i = 3: Power of the channel gain (dBm)
    % i = 4: Azimuth angle of arrival (degrees)
    % i = 5: Elevation angle of arrival (degrees)
    % i = 6: Azimuth angle of departure (degrees)
    % i = 7: Elevation angle of departure (degrees)

    null_idx = find(Info == '<ue>');
    null_idx(length(null_idx)+1) = length(Info);
    start_idx = [1; null_idx(1:end-1)+1];
    end_idx = null_idx - 1;
    Num_users = length(start_idx);    
    Paths = cell(Num_users, 1);
    for ue = 1:Num_users
        if ue == Num_users
            Paths{ue} = str2double(split(Info(start_idx(ue):end)));
        else           
            Paths{ue} = str2double(split(Info(start_idx(ue):end_idx(ue))));
        end
    end

end