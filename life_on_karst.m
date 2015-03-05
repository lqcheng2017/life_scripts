% Intialize a local matlab cluster if the parallel toolbox is available.
% This helps speeding up computations espacially for large conenctomes.
feOpenLocalCluster;

%% Name and locatio of result file to save
file2save = fullpath(savePath,'life_on_karst_results.mat')

%% Build the file names for the diffusion data, the anatomical MRI.
dwiFile       = fullfile(lifeDemoDataPath('diffusion'),'life_demo_scan1_subject1_b2000_150dirs_stanford.nii.gz');
dwiFileRepeat = fullfile(lifeDemoDataPath('diffusion'),'life_demo_scan2_subject1_b2000_150dirs_stanford.nii.gz');
t1File        = fullfile(lifeDemoDataPath('anatomy'),  'life_demo_anatomy_t1w_stanford.nii.gz');

%% (1) Evaluate the Probabilistic CSD-based connectome.
% We will analyze first the CSD-based probabilistic tractography
% connectome.
prob.tractography = 'Probabilistic';
fgFileName    = fullfile(lifeDemoDataPath('tractography'), ...
'life_demo_mrtrix_csd_lmax10_probabilistic.mat');

% The final connectome and data astructure will be saved with this name:
feFileName    = 'life_build_model_demo_CSD_PROB';

%% (1.1) Initialize the LiFE model structure, 'fe' in the code below. 
% This structure contains the forward model of diffusion based on the
% tractography solution. It also contains all the information necessary to
% compute model accuracry, and perform statistical tests. You can type
% help('feBuildModel') in the MatLab prompt for more information.
fe = feConnectomeInit(dwiFile,fgFileName,feFileName,[],dwiFileRepeat,t1File);

%% (1.2) Fit the model. 
% Hereafter we fit the forward model of tracrography using a least-squared
% method. The information generated by fitting the model (fiber weights
% etc) is then installed in the LiFE structure.
fe = feSet(fe,'fit',feFitModel(feGet(fe,'mfiber'),feGet(fe,'dsigdemeaned'),'bbnnls'));

%% (1.3) Extract the RMSE of the model on the fitted data set. 
% We now use the LiFE structure and the fit to compute the error in each
% white-matter voxel spanned by the tractography model.
prob.rmse   = feGet(fe,'vox rmse');

%% (1.4) Extract the RMSE of the model on the second data set. 
% Here we show how to compute the cross-valdiated RMSE of the tractography
% model in each white-matter voxel. We store this information for later use
% and to save computer memory.
prob.rmsexv = feGetRep(fe,'vox rmse');

%% (1.5) Extract the Rrmse. 
% We show how to extract the ratio between the model prediction error
% (RMSE) and the test-retest reliability of the data.
prob.rrmse  = feGetRep(fe,'vox rmse ratio');

%% (1.6) Extract the fitted weights for the fascicles. 
% The following line shows how to extract the weight assigned to each
% fascicle in the connectome.
prob.w      = feGet(fe,'fiber weights');

save(file2save,'prob','fe')
