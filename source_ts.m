%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Algorithm for reconstructing source time series from a given set of THRESHOLDED SOURCES and sensor level EEG time-series data

% Requirements 
% Headmodel (used in the forward model computation i.e. output of ft_prepareheadmodel) present in commonfwdmodel.mat
% Average of 3-D sensor locations across all subjects (elec_new) present in commonfwdmodel.mat
% The source positions after thresholding i.e. outputs (static_TH and dynamic_TH) of source_loc.m
% Add script Filter_arp.m to path
% Output : 3D matrix in the form of timeXtrialXnodes 

% Replace '~' at all places in the code with the path to the directory containing parent folder of static_stim/dynamic_stim  

% Written by Priyanka Ghosh on 14.10.2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd /~/static_stim
% The folder static_stim/dynamic_stim contains subject-wise sensor level EEG data in Fieldtrip format including their respective T1 images and forward models generated using ForwardModel.m
Source_TH=static_TH;
% Repeat same steps for dynamic_stim and change the variable names accordingly, e.g., Source_TH=dynamic_TH

dir_name=dir('/~/static_stim');
load('/~/common_fwdmodel.mat', 'headmodel');
load('/~/common_fwdmodel.mat', 'elec_new');
HM=headmodel; clear headmodel; Elec_new=elec_new; clear elec_new;

% THIS CODE IS COMPUTATIONALLY INTENSIVE AND MATLAB MIGHT RUN OUT OF SPACE. IT IS ADVISED TO RUN IT INDIVIDUALLY ON EACH SUBJECT.

for len = 3; %reconstructs time-series for the 1st participant, repeat till len = 21 for all 19 subjects
        data_name = dir_name(len);
        load(data_name.name)    
	cfg        = []; 
	cfg.toilim = [0.001 1];                       
	data_td   = ft_redefinetrial(cfg, data_combined); %use sensor-level time-series data for which source-level time-series is being reconstructed
	Data=ft_timelockanalysis(cfg, data_td);
	FwdmodelOutputs.HM=HM;
	FwdmodelOutputs.Realignsens=Elec_new;
	cfg=[];
	cfg.method='eloreta';
	cfg.headmodel    =  FwdmodelOutputs.HM;
	cfg.elec         =  FwdmodelOutputs.Realignsens;
	cfg.elec.unit    = 'mm';
	cfg.senstype     =  'EEG';
	cfg.eloreta.lambda  =  0.05;
	cfg.eloreta.realfilter = 'yes';
	cfg.eloreta.projectnoise='yes';
	cfg.grid.pos     = Source_TH;
	cfg.grid.inside  = true(size(Source_TH,1),1);
	cfg.eloreta.keepfilter = 'yes';
	cfg.grid.unit    = HM.unit;
	source_td= ft_sourceanalysis(cfg, Data);
end
clearvars -except Elec_new HM LeadFld Source_TH cfg data_td dir_name source_td Data IDX C X* Beamformer


%% Generating the dataset of the reconstructed time series
channel = ft_channelselection('all', Elec_new);
channel = match_str(Data.label,channel);
Recon_data = [];
Recon_data.label = {Data.label Data.label Data.label}; 
Recon_data.time  = Data.time;
Beamformer = source_td.avg.filter;

%% Extracting the spatial filter for the individual sources above the threshold
for i=1:length(Beamformer)
    Recon_data.trial{i}=Beamformer{i}(:,channel)*Data.avg;
end
clear i

%% Projecting along the strongest dipole direction
tmser=cat(2,Recon_data.trial{:,:});
[u1, s1, v1]=svd(tmser, 'econ');
tmser = [];
tmser.label = 'reconst_tm';
tmser.time = Data.time;
for i=1:length(Beamformer)
    tmser.trial{i} = u1(:,1)' * Beamformer{i}(:,channel)*Data.avg;
end
ts=cell2mat(permute(tmser.trial, [2 3 1]));

%% Node-wise grouping and averaging of the reconstructed time-series  
[IDX,C,sumd]=kmeans(Source_TH,5);  %change no. of clusters to 7 for dynamic_stim
for a=1:length(ts);
    if IDX(a)==1;
        grp1(a,:)=ts(a,:);
    end
    if IDX(a)==2;
        grp2(a,:)=ts(a,:);
    end
    if IDX(a)==3;
        grp3(a,:)=ts(a,:);
    end
    if IDX(a)==4;
        grp4(a,:)=ts(a,:);
    end
    if IDX(a)==5;
        grp5(a,:)=ts(a,:);
    end
end
grp1 = grp1(~all(grp1 == 0, 2),:); node1=mean(grp1,1);
grp2 = grp2(~all(grp2 == 0, 2),:); node2=mean(grp2,1);
grp3 = grp3(~all(grp3 == 0, 2),:); node3=mean(grp3,1);
grp4 = grp4(~all(grp4 == 0, 2),:); node4=mean(grp4,1);
grp5 = grp5(~all(grp5 == 0, 2),:); node5=mean(grp5,1);
clearvars -except node1 node2 node3 node4 node5 Source_TH IDX C X* Beamformer

%% To remove non-stationarities from time-series
% Removing evoked-potentials using a 5Hz high-pass filter to make the signals stationary 
Fs=1000; hi=45; low=5;
node1=Filter_arp(node1,hi,low,Fs); 
node2=Filter_arp(node2,hi,low,Fs); 
node3=Filter_arp(node3,hi,low,Fs);
node4=Filter_arp(node4,hi,low,Fs); 
node5=Filter_arp(node5,hi,low,Fs); 

X=node1; X(2,:)=node2; X(3,:)=node3; X(4,:)=node4; X(5,:)=node5; 
% Consider this as channelXtime matrix for first trial. Save X and repeat all steps for all 19 subjects to get all 19 trials
% Rearrange the matrix using PERMUTE into a 3D martix in the form timeXtrialXchannel (channels here will be the nodes)