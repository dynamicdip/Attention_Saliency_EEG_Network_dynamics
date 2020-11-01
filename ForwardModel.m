%% About : This code generates the leadfield matrices of individual subjects

% Requirements : MR images(in NIFTI format) and 3D Polhemus data (.dat files) of individual subjects

%% Importing MRI, reslice and confirm axis

% import individual subject MRI available in NIfTI format
mri = ft_read_mri('/home/priyanka/Documents/ATTENTION_PROJECT/EEG/t1images/Subject.nii'); %enter subject file name in nifti format in place of Subject.nii

% Reslice to standard volume 
cfg= [];
cfg.dim= [256 256 256];
mri= ft_volumereslice(cfg,mri);

% confirm x,y,z axis according to talairach
mri.coordsys = 'tal';
mri = ft_convert_units(mri,'mm');
mri= ft_determine_coordsys(mri, 'interactive', 'yes');

%% Segmentation, Mesh, Headmodel

% segment mri into brain, skull and scalp. Check for any other types of segmentation
cfg=[];
cfg.skullsmooth = 20;
cfg.scalpsmooth = 20;
%cfg.cond=[[0.330000000000000,0.004125000000000,0.330000000000000]];
cfg.output={'brain' 'skull' 'scalp'};
segmentedmri1=ft_volumesegment(cfg,mri);


%to visualize segmentation, change funparameter accordingly
cfg=[];
cfg.funparameter={'brain'};
ft_sourceplot(cfg,segmentedmri1);

%prepare mesh. choose high number of vertices, most in brain, second in skull, least in scalp.
cfg=[];
cfg.tissue={'brain' 'skull' 'scalp'};
cfg.numvertices = [4000 2000 2000];
bnd=ft_prepare_mesh(cfg,segmentedmri1);


%prepare headmodel
cfg=[];
cfg.method='bemcp';
cfg.tissue={'brain' 'skull' 'scalp'};
headmodel = ft_prepare_headmodel(cfg, ft_convert_units(bnd,'mm'));

%to visualize headmodel in 3D space, change the alpha parameter to change the opacity
figure;
ft_plot_vol(headmodel, 'facecolor', 'cortex'); alpha 0.5;
axis on; grid on; xlabel('X'); ylabel('Y'); zlabel('Z');

%% Prepare MNI fiducials dataset
% to align the fiducials, use ft_volumerealign, interactively
cfg.method='interactive';
cfg.coordys='ctf';
[mri] = ft_volumerealign(cfg, mri);

% run the rest of the section fully, elec_mni is the final dataset.
%align electrodes to mri with fiducials
vox_Nas = mri.cfg.fiducial.nas;  %mark nasion
vox_Lpa = mri.cfg.fiducial.lpa;  %mark left pre-auricular   
vox_Rpa = mri.cfg.fiducial.rpa;  %mark right pre-auricular
voxtransformation = mri.transform; % transformation matrix of individual MRI


%transform voxel indices of MRI to headcoordinates in mm
head_Nas= ft_warp_apply(voxtransformation, vox_Nas, 'homogenous'); % nasion 
head_Lpa= ft_warp_apply(voxtransformation, vox_Lpa, 'homogenous'); % Left preauricular
head_Rpa= ft_warp_apply(voxtransformation, vox_Rpa, 'homogenous'); % Right preauricular


elec_mni.chanpos = [
  head_Nas
  head_Lpa
  head_Rpa];

elec_mni.elecpos=elec_mni.chanpos;
elec_mni.label = {'Nasion'; 'Left'; 'Right';};

elec_mni.unit  = 'mm';
elec_mni.pos=elec_mni.elecpos;

%% Prepare polhemus dataset

% import polhemus data
elec_pol = importdata(['/home/priyanka/Documents/ATTENTION_PROJECT/EEG/EEG_polymus/Subject.DAT']);%AvgElecpos; 

% This part is based on the data in 3D Polhemus .DAT file acquired in the lab. 
% If using a template, check out the data and make same kind os datastructure -elec.
elec.label=elec_pol.textdata(1:67);
elec.elecpos=elec_pol.data(1:67,2:4)*10; % *10 to change the unit
elec.unit='mm';
elec.chanpos=elec.elecpos;

%% Sensor Realign

% fieldtrip accepts if the data structure is ok. elec is polhemus datastr,
% elec_mni is fiducial datastr
a=ft_datatype_sens(elec);
b=ft_datatype_sens(elec_mni);

% aligns the fiducials and accordingly, the electrodes. Final dataset
% elec_new
cfg = [];
cfg.method   = 'fiducial';
cfg.target = ft_convert_units(b,'mm');
cfg.target.pos(1,:)=head_Nas;
cfg.target.pos(2,:)=head_Lpa;
cfg.target.pos(3,:)=head_Rpa;
cfg.target.label={'Nasion';'Left';'Right'};
cfg.elec     = ft_convert_units(a,'mm');
cfg.fiducial = {'Nasion'; 'Left'; 'Right'};
elec_new = ft_electroderealign(cfg);

% Visualize and edit. Adjust x, y, z of all electrodes to align the
% electrodes as close to the scalp possible. 

Z = elec.elecpos(:,3);
Y = elec.elecpos(:,2);
X = elec.elecpos(:,1);

% X=X+1;
% Z=Z-1;
% Y=Y-2;

figure;
scatter3(X,Y,Z,'filled');
text(X,Y,Z,elec_new.label);
hold on;
ft_plot_vol(headmodel, 'facecolor','cortex');
axis on;grid on;xlabel('X');ylabel('Y');zlabel('Z');alpha 0.5;
view(0,90);
hold off;

% Once done with the visualization, put in the final coordinates in
% elec_new
elec_new.elecpos=[X Y Z];
elec_new.chanpos=elec_new.elecpos;

%% Leadfield (Check all parameters in documentation) 

cfg                 = [];
cfg.grid.warpmni = 'yes';
cfg.grid.nonlinear = 'yes';
cfg.moveinward = 1; % actually uses vol mesh
cfg.inwardshift = 0; % needs to be expressed to work with moveinward
cfg.reducerank      = 3; % 3 for EEG, 2 for MEG
cfg.vol  =  ft_convert_units(headmodel,'mm'); % already computed
cfg.elec =  ft_convert_units(elec_new,'mm');% already computed
cfg.elec.unit='mm'; %error otherwise
cfg.channel         = {'EEG'};
cfg.grid.resolution = 5;   % use a 3-D grid with a 5 mm resolution
cfg.grid.unit       = 'mm';

cfg.normalize='yes';
[Avg_LeadFld] = ft_prepare_leadfield(cfg);
