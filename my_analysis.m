
%Runs melodic spatial ICA on the fMRI files names listed in the script

cmd = 'spatial_ICA.sh'; 
system(cmd);


%Reads from specified txt files to get paths to eeg outputs and uses them to form EEG power time courses
OUT = eeg_power_ts('/fs1/neurdylab/projects/jICA/test_pipeline/EEG_data/EEG_data.txt');


%Uses output from previous line to convolve the EEG power time courses with the HRF
cd /fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/;
convolve_hrf;


%Dual regression of spatial ICA results to single subject fMRI
OUT = dual_reg_loop('/fs1/neurdylab/projects/jICA/test_pipeline/fmri_data/fmri_data.txt');


%Prepare joint time courses for jICA
make_data_for_jICA;


%Perform jICA using icasso (default 2:30 components, 50 epochs):rom
run_jICA;


%Code for plotting components to be added later


%Dual regression of jICA results to single subject
jica_dual_reg;

%Project subject jICA to voxel
subject_jICA_maps('/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/single_subject_jICA_projections');

%Dual regression of jICA results to single subject EEG
jica_eeg_dual_reg;


%Prepare fMRI data for FSL randomise analysis, need to load FSL for merging the niftis with fslmerge
average_subject_voxels;
make_niftis_for_ttest;
average_subject_jICA;


%Randomise analysis using FSL
cmd_02 = 'ttest_fsl.sh';
system(cmd_02);


%EEG electrode ttest with Benjamini-Hochberg correction
ttest_eeg;


%Plot comparison results to be added later


%Spectral analysis of components
create_ts_for_spec;
spectral_analysis;






