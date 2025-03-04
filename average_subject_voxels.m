

% Define the parent directory
parent_dir = './single_subject_jICA_projections/spatial_maps'; % Change this to your actual path

% Create the directory to move multiple observations
multi_obs_dir = fullfile(parent_dir, 'multiple_observations');
if ~exist(multi_obs_dir, 'dir')
    mkdir(multi_obs_dir);
end

% Get a list of all directories in the parent directory
dir_list = dir(fullfile(parent_dir, '*-scan*'));
dir_names = {dir_list.name};
disp(dir_names)

% Group directories by patient ID (first 6 characters)
patient_ids = cellfun(@(x) x(1:6), dir_names, 'UniformOutput', false);
disp(patient_ids)
unique_patids = unique(patient_ids);

% Loop through unique patient IDs to find those with two scans
for i = 1:length(unique_patids)
    patid = unique_patids{i};
    
    % Find directories matching the patient ID
    pat_dirs = dir_list(startsWith(dir_names, patid));
    
    if length(pat_dirs) == 2
        % Found a patient with two scans
        disp(['Averaging scans for patient: ', patid]);

        % Create the new directory for the averaged scan
        new_scan_dir = fullfile(parent_dir, [patid, '-scan03']);
        if ~exist(new_scan_dir, 'dir')
            mkdir(new_scan_dir);
        end
        
        % Get the list of NIfTI files from both scan directories
        scan1_dir = fullfile(parent_dir, pat_dirs(1).name);
        scan2_dir = fullfile(parent_dir, pat_dirs(2).name);
        nifti_files1 = dir(fullfile(scan1_dir, 'fmri_*.nii'));
        nifti_files2 = dir(fullfile(scan2_dir, 'fmri_*.nii'));
        
        % Check if the number of NIfTI files matches in both directories
        if length(nifti_files1) ~= length(nifti_files2)
            warning(['Mismatch in NIfTI files for ', patid, '. Skipping...']);
            continue;
        end
        
        % Loop through the NIfTI files and perform voxel-wise averaging
        for j = 1:length(nifti_files1)
            % Load the NIfTI files
            nifti1 = fullfile(scan1_dir, nifti_files1(j).name);
            nifti2 = fullfile(scan2_dir, nifti_files2(j).name);
            nii1 = niftiread(nifti1);
            nii2 = niftiread(nifti2);
            
            % Perform voxel-wise averaging
            averaged_nii = (nii1 + nii2) / 2;
            
            % Save the averaged NIfTI file in the new scan03 directory
            output_nifti = fullfile(new_scan_dir, nifti_files1(j).name);
            niftiwrite(averaged_nii, output_nifti);
        end
        
        % Move the original directories to the 'multiple_observations' folder
        movefile(scan1_dir, fullfile(multi_obs_dir, pat_dirs(1).name));
        movefile(scan2_dir, fullfile(multi_obs_dir, pat_dirs(2).name));
        
        disp(['Averaging complete for ', patid, '.']);
    end
end

disp('Averaging process completed for all patients.');
