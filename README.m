%% This script outlines the analysis to generate the figures of manuscript Ghosh, Roy , Banerjee 2020

% All data and toolboxes used for figures are present in https://drive.google.com/drive/u/2/folders/1vpib8ZnWkQU-YBWhfacwk3ATKFK8n_cM
%
% All pre-processed EEG time-series and corresponding reaction times are in file timeser&rt.mat 
%
% Fieldtrip format data for Dynamic stimulus is in dynamic_stim folder and for Static stimulus in static_stim folder
%
% We recommend to download individual subject .mat files and save it in the respective folders named dynamic_stim/static_stim instead of directly downloading the entire folder from the drive
% (This is to avoid issues of incomplete downloads noticed by us; Google drive downloads are restricted to 2GB and the datasets get rearranged in the process of zipping the folder for download)
%
% Other associated folders that need to be added to matlab path are the Fieldtrip, Chronux and EEGLAB toolbox 


% Written by Priyanka Ghosh and Arpan Banerjee on 14.10.2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% -------------------------------Fig.2----------------------------------------------

% Download mat file named timeser&rt.mat from https://drive.google.com/drive/u/2/folders/1vpib8ZnWkQU-YBWhfacwk3ATKFK8n_cM
% 
% For generating condition-wise reaction time plots, load all the variables with prefix 'rt' into the workspace.
% 
% Run the matlab script reaction_time.m to generate scatter plots and box-plots for static and dynamic stimulus
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% -------------------------------Fig.3----------------------------------------------

% Add Chronux toolbox(we used chronux_2_12) and EEGLAB toolbox(we used eeglab 14_1_1b) to matlab path
% 
% Download mat file named timeser&rt.mat from https://drive.google.com/drive/u/2/folders/1vpib8ZnWkQU-YBWhfacwk3ATKFK8n_cM
%
% For generating powerspectrum plots of static stimulus, load variables with suffix 'static' into the workspace
% For generating powerspectrum plots of dynamic stimulus, load variables with suffix 'dynamic' into the workspace
%
% All time-series data are arranged as 3D matrices in the form of time-series*channels*trials 
%
% Run the matlab script powerspec.m to generate powerspectrum plots and corresponding topoplots for static and dynamic stimulus

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% -------------------------------Fig.4----------------------------------------------

% Download and add to matlab path : Fieldtrip toolbox(we used fieldtrip-20181105), @gifti folder and 'coords2surf2.m' from https://drive.google.com/drive/u/2/folders/1vpib8ZnWkQU-YBWhfacwk3ATKFK8n_cM 
%
% Download folders static_stim/dynamic_stim and each folder should contain subject-wise data of all 19 subjects
%
% Run matlab script source_loc.m to localize subject-wise sources of alpha power enhancement and to compute statistics over the grand-average across all subjects for static and dynamic stimulus
%
% Output: Brain plots with the thresholded sources for static and dynamic stimulus

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% -------------------------------Fig.5----------------------------------------------

% Download mat file named common_fwdmodel.mat from https://drive.google.com/drive/u/2/folders/1vpib8ZnWkQU-YBWhfacwk3ATKFK8n_cM
%
% Download script Filter_arp and put it in matlab path
%
% Fieldtrip toolbox(we used fieldtrip-20181105) should be present in matlab path
%
% Run matlab script source_ts.m to reconstruct source-level time-series from the sensor-level time-series data and the spatial filter of the thresholded sources
%
% Input : Outputs of source_loc.m, 'static_TH' and 'dynamic_TH' 
%
% Use static_TH as Source_TH for static stimuli and dynamic_TH as Source_TH for dynamic stimuli in the source_ts.m code
%
% Output : Source time-series in the form of 3D matrix for time. trial. channel 
%
% Run a stationarity check on the output time-series using the matlab function adftest
%
% Run matlab script GC_spectral.m for performing Granger Causality analysis on stationary time-series
% 
% Input : Output of source_ts.m; fs=1000; fRes=1; 
%
% Using the output 'causality' which consists of causal scores at all frequencies(0-500Hz), extract only the causal scores between 8-9 Hz.
%
% For computing statistics, do a permutation test (refer to manuscript) and use GC_spectral.m again for performing the TRGC
% 
% For generating the directed functional connectivity figures, add BrainNetviewer to matlab path (download link https://www.nitrc.org/projects/bnv/) 
