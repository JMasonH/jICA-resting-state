

% Define input and output directories
data_dir = './single_subject_jICA_projections/spatial_maps';
brain_mask_file = '/fs1/neurdylab/projects/jICA/MNI152_T1_2mm_brain_mask_filled.nii.gz';

output_dir = fullfile(data_dir, 't-test');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Get list of all subject directories
subject_dirs = dir(fullfile(data_dir, 'v*'));
control_dirs = {};
patient_dirs = {};
%scan_ids = {};

% Separate directories into control (vcon) and patient (vpat) groups
for i = 1:length(subject_dirs)
    if subject_dirs(i).isdir
        if startsWith(subject_dirs(i).name, 'vcon')
            control_dirs{end+1} = fullfile(data_dir, subject_dirs(i).name);
        elseif startsWith(subject_dirs(i).name, 'vpat')
            patient_dirs{end+1} = fullfile(data_dir, subject_dirs(i).name);
        end
    end
end

% Check if both groups have subjects
if isempty(control_dirs) || isempty(patient_dirs)
    error('No control or patient directories found.');
end


for comp_num = 1:80
    comp_str = num2str(comp_num);  
    control_files = {};
    patient_files = {};
    
    % Collect NIfTI files for controls
    for i = 1:length(control_dirs)
        nifti_file = fullfile(control_dirs{i}, ['fmri_', comp_str, '.nii']);
        if exist(nifti_file, 'file')
            control_files{end+1} = nifti_file;
            [~, dir_name] = fileparts(control_dirs{i});
            %scan_ids{end+1} = dir_name; % Store the control scan ID
        else
            warning(['Missing file: ', nifti_file]);
        end
    end


    % Collect NIfTI files for patients
    for i = 1:length(patient_dirs)
        nifti_file = fullfile(patient_dirs{i}, ['fmri_', comp_str, '.nii']);
        if exist(nifti_file, 'file')
            patient_files{end+1} = nifti_file;
            [~, dir_name] = fileparts(patient_dirs{i});
            %scan_ids{end+1} = dir_name; % Store the control scan ID
        else
            warning(['Missing file: ', nifti_file]);
        end
    end
    %all_scan_ids = transpose[scan_ids]; % This maintains the order of the files

    % Display the scan IDs
    % disp('Scan IDs:');
    % disp(all_scan_ids);
    disp(numel(control_files));
    disp(numel(patient_files));

    all_files = [control_files, patient_files];
    

    % Check if we have enough files for both groups
    if isempty(control_files) || isempty(patient_files)
        warning(['Not enough NIfTI files for component ', comp_str, '. Skipping...']);
        continue;
    end
    
    % Create 4D NIfTI files for the two groups
    group_4D = fullfile(output_dir, ['comp_', comp_str, '_4D.nii.gz']);
   
    
    % Merge control and patient NIfTI files into 4D files
    system(['fslmerge -t ', group_4D, ' ', strjoin(all_files)]);
    

    g = niftiread(group_4D);
    
    disp(size(g));
end
