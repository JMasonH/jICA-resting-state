%spatial maps


ICA_components= niftiread('/fs1/neurdylab/projects/jICA/test_pipe/melodic_IC.nii.gz'); 
maskfile = '/fs1/neurdylab/projects/jICA/MNI152_T1_2mm_brain_mask_filled.nii.gz'; 
 


brain_mask = niftiread(maskfile);
dims = size(brain_mask);
mask_inds = find(brain_mask ~= 0);
 
if ~exist('./group_jICA_results/group_component_maps/fmri', 'dir')
    mkdir('./group_jICA_results/group_component_maps/fmri');
end

if ~exist('./group_jICA_results/group_component_maps/eeg', 'dir')
    mkdir('./group_jICA_results/group_component_maps/eeg');
end




%%
addpath('./group_jICA_results');
c_delta = load('delta-jica_full.mat');
d = c_delta.OUT.A;
c_theta = load('theta-jica_full.mat');
t = c_theta.OUT.A;
c_alpha = load('alpha-jica_full.mat');
a = c_alpha.OUT.A;
c_beta = load('beta-jica_full.mat');
b = c_beta.OUT.A;
c_gamma = load('gamma-jica_full.mat');
g = c_gamma.OUT.A; 

tica_mat = cat(2, d,t,a,b,g);

% vox = reshape(ICA_components, [], 40);
MRI_1d = zeros(229694, 40); 

for n = 1:40
    ic = ICA_components(:,:,:,n);
    MRI_1d(:, n) = ic(mask_inds);
end

new_dims = transpose(dims(:)); 

[row, col] = size(tica_mat);
 
MRI_recover_3D = zeros([new_dims,col]);

%loop through each component: 8, 16 * 5
for i = 1:col 

       %separate the fMRI signals from the EEG, multiply
       fmri_mix = tica_mat(27:66, i); 
       ic_map = MRI_1d*fmri_mix;

       temp = zeros(dims);
       temp(mask_inds) = ic_map; 

       MRI_recover_3D(:,:,:,i) = temp;
end

%%
% i changes for # joint comps

output_dir = './group_jICA_results/group_component_maps/fmri'; 
hdr = niftiinfo(maskfile);
hdr.Datatype='double';
for i = 1:col
    vol = MRI_recover_3D(:,:,:,i);
    nifti_filename = fullfile(output_dir, ['jICA_fmri_', num2str(i), '.nii']);
    niftiwrite(vol, nifti_filename, hdr);
end

%%


dummy = load('/data1/neurdylab/datasets/eegfmri_vu/PROC/vpat17/eeg/scan01/vpat17-scan01_eeg_pp.mat');
addpath('/fs1/neurdylab/software/eeglab2021');

eeglab;


%%


brain_ch = 1:26;
chanlocs_use = dummy.EEG.chanlocs(brain_ch);

% eeg_vector = tica_mat(1:26, 4);
% 
% % [~, map_value]= 
% topoplot(eeg_vector, chanlocs_use, 'style', 'map', 'hcolor', 'none', 'electrodes', 'off');

% i changes for # joint comps

save_dir = './group_jICA_results/group_component_maps/eeg';

for i = 1:col
    eeg_vector = tica_mat(1:26, i); % Extract the vector for the ith band
    figure;
    
    topoplot(eeg_vector, chanlocs_use, 'maplimits', 'maxmin', 'electrodes', 'on');
    
    title(sprintf('Scalp Map for Component %d', i));
    colorbar; 

    savefig(fullfile(save_dir, sprintf('jICA_eeg_%d.fig', i)));
    close(gcf);
end
%%
