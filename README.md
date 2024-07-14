# Ray tracing dataset
This is a ray-tracing dataset for an RIS-aided mmWave system operating in an indoor factory environment. This dataset is generated for the paper "RIS-aided Joint Channel Estimation and Localization at mmWave under Hardware Impairments: A Dictionary Learning-based Approach".

# Dataset info
The locations of the devices and the related channel information are in the `data` folder. The locations of the BS, RIS and MSs are in `data/AP_pos.txt`, `data/RIS_pos.txt` and `data/UE_pos.txt`, respectively. The information related to paths of the channels are contained in the `data/Info_BM.txt`, `data/Info_BR.txt` and `data/Info_RM.txt` for the BS-MS, BS-RIS and RIS-MS channels, respectively. Each path has the following information: Phase of the channel gain, delay, channel gain, azimuth AoA, elevation AoA, azimuth AoD, and elevation AoD.

# How to use the dataset
The `example.m` code can be run to observe how to import the dataset and generate the channels. This code also produces an example plot showing the spectral efficiency vs RIS size. The function `channel_import.m` is used for extracting the information of the paths from the given files. The usage of this function can be observed in `example.m`.

# Citation
@article{Bayraktar2024,
  title={{RIS}-aided joint channel estimation and localization at {mmWave} under hardware impairments: A dictionary learning-based approach},
  author={Bayraktar, Murat and and González-Prelcic, Nuria and Alexandropoulos, George K. and Chen, Hao},
  journal={arXiv preprint},
  year={2024}
}
