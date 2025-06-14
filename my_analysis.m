%spm_path is path to SPM12 installation
%fastica_path is path to fastica installation
%icasso_path is path to icasso installation
%eeglab_path is path to eeglab installation


% fmritxtPath is path to .txt files containing paths to each mri scan
% eegtxtPath is path to .txt files containing paths to each eeg scan
% melodicbash is path to bash script that runs melodic on the fMRI scans

%maskPath is path to brain mask .nii.gz file
%eeg_dummy_path is path to eeg dummy .mat file

spm_path = '/fs1/neurdylab/projects/jICA/test_pipe/spm12';
fastica_path = '/fs1/neurdylab/projects/jICA/test_pipe/fastica';
icasso_path = '/fs1/neurdylab/projects/jICA/test_pipe/icasso';
eeglab_path = '/fs1/neurdylab/software/eeglab2021';

workDir = '/fs1/neurdylab/projects/jICA/test_02/jICA-neuroimaging-epilepsy/';
fmritxtPath = '/fs1/neurdylab/projects/jICA/test_pipe/fmri_test_paths.txt';
eegtxtPath = '/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/eeg_test_paths.txt';
maskPath = '/fs1/neurdylab/projects/jICA/MNI152_T1_2mm_brain_mask_filled.nii.gz';
eeg_dummy_path = '/fs1/neurdylab/projects/jICA/test_pipe/vpat15-scan02_eeg_pp.mat';

cmd = sprintf('./spatial_ICA.sh "%s" "%s"', fmritxtPath, workDir);
status = system(cmd);

if status ~= 0
    error('spatial_ICA.sh failed to run.');
end


%Reads from specified txt files to get paths to eeg outputs and uses them to form EEG power time courses
OUT = eeg_power_ts(eegtxtPath, workDir);


%Uses output from previous line to convolve the EEG power time courses with the HRF
cd workDir;
convolve_hrf;


%Dual regression of spatial ICA results to single subject fMRI
OUT = dual_reg_loop(fmritxtPath, workDir, maskPath);


%Prepare joint time courses for jICA
make_data_for_jICA;


%Perform jICA using icasso (default 2:30 components, 50 epochs):rom
run_jICA;


%Code for plotting components to be added later


%Dual regression of jICA results to single subject
jica_dual_reg;

%Project subject jICA to voxel
subject_jICA_maps(workDir, maskPath);

%Dual regression of jICA results to single subject EEG
jica_eeg_dual_reg;


%Prepare fMRI data for FSL randomise analysis, need to load FSL for merging the niftis with fslmerge

%Example of loading FSL in terminal:
%module load GCC/5.4.0-2.26 
%module load OpenMPI/1.10.3
%module load FSL/5.0.10


average_subject_voxels;
make_niftis_for_ttest;
average_subject_jICA;

%Randomise analysis using FSL
randomise_in = fullfile(workDir, 'single_subject_jICA_projections/spatial_maps/t-test');
randomise_out = fullfile(workDir, 'single_subject_jICA_projections/spatial_maps/t-test/results');
design_mat = fullfile(workDir, 'design_test.mat');
design_con = fullfile(workDir, 'design.con');

randomise_script = fullfile(workDir, 'ttest_fsl.sh');  % path to the script you saved
cmd = sprintf('bash %s "%s" "%s" "%s" "%s" "%s"', ...
    randomise_script, randomise_in, randomise_out, design_mat, design_con, maskPath);

status = system(cmd);


%EEG electrode ttest with Benjamini-Hochberg correction
ttest_eeg;

%Plot comparison results to be added later


%Spectral analysis of components
create_ts_for_spec;
spectral_analysis;



















