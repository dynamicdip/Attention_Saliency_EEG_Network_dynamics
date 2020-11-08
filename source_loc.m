%% About: This code plots figures presented in Fig 4 of Ghosh, Roy, Banerjee 2020

% Download folders static_stim and dynamic_stim to local system

% The folders static_stim/dynamic_stim contain subject-wise sensor level EEG data in Fieldtrip format including their respective MR images and forward models generated using ForwardModel.m

% Create folders named 'stat_sources' and 'dyn_sources' in the same directory which will keep saving subject-wise source localaized data from static_stim and dynamic_stim respectively, with every iteration of the loop

% Written by Priyanka Ghosh and Arpan Banerjee on 14.10.2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---- Source localization using eLORETA (Source-current density Method) -----------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii =1:2

    if ii ==1
        dir_name=dir('/~/static_stim'); % Replace '~' in the code with the path to the directory containing the folder 'static_stim', e.g., here it becomes '/home/priyanka/Documents/codes/static_stim'  
    else if ii ==2
        dir_name=dir('/~/dynamic_stim'); % Same as above 
    end
    end
    
for len = 3:length(dir_name);
         
    if ii ==1
        cd /~/static_stim
    else if ii ==2
        cd /~/dynamic_stim    
    end
    end
    
    data_name = dir_name(len);
    load(data_name.name)
  
%For details on the Fieldtrip functions used, please visit https://www.fieldtriptoolbox.org/reference/ 


    cfg        = [];                                           
    cfg.toilim = [0.001 1];                       
    data_td   = ft_redefinetrial(cfg, data_combined);  % for trials without saliency(WT) or condition 1
    cfg.toilim = [1.001 2];                       
    data_bu   = ft_redefinetrial(cfg, data_combined);  % for trials with saliency(ST) or condition 2
    cfg = [];
    cfg.method    = 'mtmfft';
    cfg.output    = 'powandcsd';
    cfg.pad       = 'maxperlen';
    cfg.tapsmofrq = 2;
    cfg.taper     = 'dpss';
    cfg.foilim    = [8 10];
    freq_td=ft_freqanalysis(cfg,data_td);
    cfg = [];
    cfg.method    = 'mtmfft';
    cfg.output    = 'powandcsd';
    cfg.pad       = 'maxperlen';
    cfg.tapsmofrq = 2;
    cfg.taper     = 'dpss';
    cfg.foilim    = [8 10];
    freq_bu=ft_freqanalysis(cfg,data_bu);
    dataAll = ft_appenddata([], data_td, data_bu);
    cfg = [];
    cfg.method    = 'mtmfft';
    cfg.output    = 'powandcsd';
    cfg.tapsmofrq = 2;
    cfg.foilim    = [8 10];
    freqAll = ft_freqanalysis(cfg, dataAll);
    FwdmodelOutputs.LF=LeadFld;
    FwdmodelOutputs.HM=HM;
    FwdmodelOutputs.Realignsens=Elec_new;
    cfg=[];
    cfg.method='eloreta';
    cfg.grid         =  FwdmodelOutputs.LF;
    cfg.grid.unit    = 'mm';
    cfg.headmodel    =  FwdmodelOutputs.HM;
    cfg.elec         =  FwdmodelOutputs.Realignsens;
    cfg.elec.unit    = 'mm';
    cfg.senstype     =  'EEG';
    cfg.eloreta.lambda  =  0.05;
    cfg.eloreta.keepfilter = 'yes';
    cfg.eloreta.realfilter = 'yes';
    cfg.eloreta.projectnoise='yes';
    cfg.frequency=9;
    sourceAll = ft_sourceanalysis(cfg, freqAll);
    cfg.grid.filter = sourceAll.avg.filter;  %for a common spatial filter
    source_td  = ft_sourceanalysis(cfg, freq_td);
    source_bu = ft_sourceanalysis(cfg, freq_bu);
    sourceDiff = source_td;



    % calculate the AMI (alpha modulation index)
    sourceDiff.avg.pow = (source_bu.avg.pow - source_td.avg.pow)./ (0.5*(source_bu.avg.pow + source_td.avg.pow));


    % reslice volume to 256x256x256
    cfg= [];
    cfg.dim= [256 256 256];
    mri= ft_volumereslice(cfg,mri);

    % confirm x,y,z axis according to tal
    mri.coordsys = 'tal';
    mri = ft_convert_units(mri,'mm');
    cfg            = [];
    cfg.downsample = 1;
    cfg.parameter  = 'avg.pow';
    sourceDiffInt  = ft_sourceinterpolate(cfg, sourceDiff, mri);

    cfg = [];
    cfg.spmversion = 'spm8';
    cfg.template = '/~/fieldtrip-20181105/collin.nii'; 
    cfg.coordsys = 'tal';
    cfg.parameter  = 'all';
    cfg.downsample = 1;
    cfg.nonlinear  = 'no';
    sourceDiffIntNorm = ft_volumenormalise(cfg, sourceDiffInt);

        if ii ==1
           cd /~/stat_sources %create a folder 'stat_sources' in this directory beforehand
           save (['sub_source' num2str((len-2),'%02.f')], '-struct', 'sourceDiffIntNorm') ;
           else if ii ==2
           cd /~/dyn_sources %create a folder 'dyn_sources' in this directory beforehand
           save (['sub_source' num2str((len-2),'%02.f')], '-struct', 'sourceDiffIntNorm') ;
           end
        end
end
clearvars -except ii static

%% The following steps are important for averaging the source powers across all subjects 

    if ii ==1
        dir_name=dir('/~/stat_sources');
    else if ii ==2
        dir_name=dir('/~/dyn_sources');
    end
    end

for i = 3:length(dir_name)
        if ii ==1
            cd /~/stat_sources
        else if ii ==2
            cd /~/dyn_sources    
        end
        end
  data_name = dir_name(i);
  load(data_name.name);   
  isd(:,(i-2))=inside(:);
  isd_nonzero(:,(i-2))=length(find(isd(:,(i-2))~=0)); 
end

	min_isd_ind = find(min(isd_nonzero)==isd_nonzero); %finding the index of the subject with minimum number of grid points inside the brain
	clearvars -except min_isd_ind dir_name ii static
	data_name = dir_name(min_isd_ind+2);
	load(data_name.name);
	min_inside=inside;
	clearvars -except min_inside dir_name min_isd_ind ii static

% Equate the parameter 'inside' across all subjects for performing ft_sourcegrandaverage

for i = 3:length(dir_name)
     data_name = dir_name(i);
     load(data_name.name);   
     inside=min_inside;
     source(i-2).anatomy=anatomy;
     source(i-2).cfg=cfg;
     source(i-2).coordsys=coordsys;
     source(i-2).dim=dim;
     source(i-2).initial=initial;
     source(i-2).inside=inside;
     source(i-2).params=params;
     source(i-2).pow=pow;
     source(i-2).transform=transform;
end
        if ii ==1
           static=source; %subject-wise sources of alpha-power enhancement in static stimulus
        else if ii ==2
           dynamic=source; %subject-wise sources of alpha power enhancement in dynamic stimulus
        end
        end
end    
clearvars -except static dynamic


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ---Statistics-----
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Static stimulus
cfg = [];
cfg.parameter='avg.pow';
cfg.keepindividual='no';
[SourceAvg] = ft_sourcegrandaverage(cfg, static(1,1), static(1,2), static(1,3), static(1,4), static(1,5), static(1,6), static(1,7), static(1,8), static(1,9), static(1,10), static(1,11), static(1,12), static(1,13), static(1,14), static(1,15), static(1,16), static(1,17), static(1,18), static(1,19));

% Extracting the source powers and the respective positions
Temppow = SourceAvg.pow;
Temppos = SourceAvg.pos;
Temp = [Temppow Temppos];

% Sorting them using the x-axis (for dividing the postions into left and right brain)
[values order]= sort(Temp(:,2));

SortedTemp = Temp(order,:);

LB = SortedTemp(1:size(SortedTemp,1)/2,:); RB = SortedTemp((size(SortedTemp,1)/2)+1:end,:);

% Getting the quantile value for thresholding
qp = 0.95; 

LB_pow = LB(:,1); LB_pos = LB(:,2:4); LB_threshold = quantile(LB_pow, qp);
RB_pow = RB(:,1); RB_pos = RB(:,2:4); RB_threshold = quantile(RB_pow, qp);


% Remove spurious activations from inside the brain (since we are dealing with cortical activations only) by masking the central noise with an ellipsoid 
for i=1:size(LB_pos,1);
 if abs(LB_pos(i,1))<25 || LB_pos(i,2)<-25 || LB_pos(i,3)<-5
    LB_pow(i,1)=NaN; 
 end
end

for i=1:size(RB_pos,1);
 if abs(RB_pos(i,1))<25 || RB_pos(i,3)<-5 
    RB_pow(i,1)=NaN; 
 end
end

LB_ind = find(LB_pow > LB_threshold); RB_ind = find(RB_pow > RB_threshold);
LB_static = LB_pos(LB_ind,:); RB_static = RB_pos(RB_ind,:);

static_TH =[RB_static; LB_static]; %thresholded sources of static stimulus

% plot
figure1= figure('Color',[1 1 1],'Name','sources processing saliency during static stimulus'); 
subplot(1,3,1); axis off;
set(subplot(1,3,1), 'Position', [0.0242708333333333 0.0901881918819187 0.321666666666667 0.876383763837639]);
coords2surf2(static_TH,[],[]);view([-1 0 0]);
subplot(1,3,2);axis off;
set(subplot(1,3,2), 'Position', [0.370797101449275 0.144686346863469 0.240036231884058 0.788154981549816]);
coords2surf2(static_TH,[],[]);view([0 0 1]);
subplot(1,3,3);axis off;
set(subplot(1,3,3), 'Position', [0.6308453125 0.0901881918819187 0.321666666666667 0.876383763837639]);
coords2surf2(static_TH,[],[]);view([1 0 0]);
clearvars -except static_TH static dynamic
_________________________________________________________________________________________________________________________________________________________________________________________________

% Dynamic stimulus

cfg = [];
cfg.parameter='avg.pow';
cfg.keepindividual='no';
[SourceAvg] = ft_sourcegrandaverage(cfg, dynamic(1,1), dynamic(1,2), dynamic(1,3), dynamic(1,4), dynamic(1,5), dynamic(1,6), dynamic(1,7), dynamic(1,8), dynamic(1,9), dynamic(1,10), dynamic(1,11), dynamic(1,12), dynamic(1,13), dynamic(1,14), dynamic(1,15), dynamic(1,16), dynamic(1,17), dynamic(1,18), dynamic(1,19));

% Extracting the source powers and the respective positions
Temppow = SourceAvg.pow;
Temppos = SourceAvg.pos;
Temp = [Temppow Temppos];

% Sorting them using the x-axis (for dividing the postions into left and right brain)
[values order]= sort(Temp(:,2));

SortedTemp = Temp(order,:);

LB = SortedTemp(1:size(SortedTemp,1)/2,:); RB = SortedTemp((size(SortedTemp,1)/2)+1:end,:);

% Getting the quantile value for thresholding
qp = 0.95; 

LB_pow = LB(:,1); LB_pos = LB(:,2:4); LB_threshold = quantile(LB_pow, qp);
RB_pow = RB(:,1); RB_pos = RB(:,2:4); RB_threshold = quantile(RB_pow, qp);

% Remove spurious activations from inside the brain (since we are dealing with cortical activations only) by masking the central noise with an ellipsoid 
for i=1:size(LB_pos,1);
 if abs(LB_pos(i,1))<25 || LB_pos(i,3)<-5 
    LB_pow(i,1)=NaN; 
 end
end

for i=1:size(RB_pos,1);
 if abs(RB_pos(i,1))<25 || RB_pos(i,3)<-5 
    RB_pow(i,1)=NaN; 
 end
end

LB_ind = find(LB_pow > LB_threshold); RB_ind = find(RB_pow > RB_threshold);
LB_dynamic = LB_pos(LB_ind,:); RB_dynamic = RB_pos(RB_ind,:);

dynamic_TH =[RB_dynamic; LB_dynamic]; %thresholded sources of dynamic stimulus

% plot

figure1= figure('Color',[1 1 1],'Name','sources processing saliency during dynamic stimulus'); 
subplot(1,3,1); axis off;
set(subplot(1,3,1), 'Position', [0.0242708333333333 0.0901881918819187 0.321666666666667 0.876383763837639]);
coords2surf2(dynamic_TH,[],[]);view([-1 0 0]);
subplot(1,3,2);axis off;
set(subplot(1,3,2), 'Position', [0.370797101449275 0.144686346863469 0.240036231884058 0.788154981549816]);
coords2surf2(dynamic_TH,[],[]);view([0 0 1]);
subplot(1,3,3);axis off;
set(subplot(1,3,3), 'Position', [0.6308453125 0.0901881918819187 0.321666666666667 0.876383763837639]);
coords2surf2(dynamic_TH,[],[]);view([1 0 0]);
clearvars -except static_TH dynamic_TH static dynamic