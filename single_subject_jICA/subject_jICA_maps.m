
function subject_jICA_maps(data_dir) 

sub_mat = dir(fullfile(data_dir, '*.mat'));

addpath('/fs1/neurdylab/projects/jICA/');
addpath('/fs1/neurdylab/software/eeglab2021')
blank_scalp = load("/fs1/neurdylab/datasets/eegfmri_vu/PROC/vpat15/eeg/scan02/vpat15-scan02_eeg_pp.mat");
eeglab;

maskfile = "fs1/neurdylab/projects/jICA/MNI152_T1_2mm_brain_mask_filled.nii.gz"; %control ic maps


brain_mask = niftiread(maskfile);
dims = size(brain_mask);
mask_inds = find(brain_mask ~= 0);

for i = 1:length(sub_mat)

    mat = load(fullfile(data_dir, sub_mat(i).name));

    
    n = 13;  % Specify the number of characters to keep
    [~, fileName] = fileparts(sub_mat(i).name);
      
    if length(fileName) > n
      fileName = fileName(1:n);
    end

    id = fileName(1:6);
    scan = fileName(8:13);

    folderName = ['/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/single_subject_jICA_projections/spatial_maps/', id, '-', scan];  % Specify the folder name

    if ~exist(folderName, 'dir')
        mkdir(folderName);
        disp(['Directory created: ' folderName]);
    else
        disp(['Directory already exists: ' folderName]);
    end

    save_dir = folderName;

    %/fs1/neurdylab/datasets/eegfmri_vu/PROC/vcon12/meica_proc_scan01/meica_out/vcon12-scan01_EPI2MNI_sm.nii.gz

    fmri = load(['/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/fmri_projections/', id, '-', scan, '_IC_reg.mat']);
    spatmap = fmri.OUT.spatial;
    sub_spatmap = spatmap(2:end, :);

    u = height(mat.OUT.spatial);

  
    for j = 1:5
        
        for n = 1:height(mat.OUT.spatial)

            spatial_mri = mat.OUT.spatial(n, 27:66, j);
            spatial_eeg = mat.OUT.spatial(n, 1:26, j);
       
            MRI_recover_3D = zeros(transpose(dims(:)));

            %separate the fMRI signals from the EEG, multiply
            row = (u*(j-1))+n;
        
            ic_map = sub_spatmap'*spatial_mri';
            temp = zeros(dims);
            temp(mask_inds) = ic_map; 

            MRI_recover_3D(:,:,:) = temp;
        
            brain_ch = 1:26;
            chanlocs_use = blank_scalp.EEG.chanlocs(brain_ch);

            figure;
    
            topoplot(spatial_eeg, chanlocs_use, 'maplimits', 'maxmin', 'electrodes', 'on');
        
            title(sprintf('Scalp Map for Component %d', row));
            colorbar; 

            savefig(fullfile(save_dir, sprintf('full_eeg_%d.fig', row)));
            close(gcf);
            
            hdr = niftiinfo(maskfile);
            hdr.Datatype='double';

            vol = MRI_recover_3D(:,:,:);
            nifti_filename = fullfile(save_dir, ['fmri_', num2str(row) '.nii']);
            niftiwrite(vol, nifti_filename, hdr);
           
        end
    end
end
