
% Define the parent directory
base_dir = '/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/single_subject_jICA_projections';

% Define output directories
patients_dir = fullfile(base_dir, 'patients');
controls_dir = fullfile(base_dir, 'controls');
multiple_obs_dir = fullfile(base_dir, 'multiple_observations');

% Create output directories if they dont exist
if ~exist(patients_dir, 'dir')
    mkdir(patients_dir);
end
if ~exist(controls_dir, 'dir')
    mkdir(controls_dir);
end
if ~exist(multiple_obs_dir, 'dir')
    mkdir(multiple_obs_dir);
end

% Get list of all .mat files in the parent directory
mat_files = dir(fullfile(base_dir, '*_jICA.mat'));

% Extract subject IDs and scan numbers from filenames
file_info = struct();
for i = 1:length(mat_files)
    filename = mat_files(i).name;
    subject_id = filename(1:13); % First 13 characters are subject ID and scan number
    file_info(i).subject_id = subject_id;
    file_info(i).filepath = fullfile(base_dir, filename);
end

% Group files by subject ID (first 6 characters)
subject_ids = unique(cellfun(@(x) x(1:6), {file_info.subject_id}, 'UniformOutput', false));
for i = 1:length(subject_ids)
    subject_id = subject_ids{i};
    
    % Find all files for this subject
    subject_files = file_info(startsWith({file_info.subject_id}, subject_id));
    
    % Determine if the subject is a patient or control
    if contains(subject_files(1).filepath, 'vpat')
        group_dir = patients_dir;
    elseif contains(subject_files(1).filepath, 'vcon')
        group_dir = controls_dir;
    else
        warning(['Subject ' subject_id ' has an unknown type (neither vpat nor vcon). Skipping...']);
        continue;
    end
    
    % If there are exactly two scans, average them
    if length(subject_files) == 2
        % Load the two .mat files
        data1 = load(subject_files(1).filepath);
        data2 = load(subject_files(2).filepath);
        
        % Average the OUT.spatial matrices
        avg_spatial = (data1.OUT.spatial + data2.OUT.spatial) / 2;
        
        % Keep the OUT.time_series from one of the original files
        time_series = data1.OUT.time_series;
        
        % Create the new OUT structure
        OUT.spatial = avg_spatial;
        OUT.time_series = time_series;
        
        % Save the averaged data with a new filename
        new_filename = [subject_id '-scan03_jICA.mat'];
        save(fullfile(group_dir, new_filename), 'OUT');
        
        % Move the original files to the multiple_observations directory
        movefile(subject_files(1).filepath, multiple_obs_dir);
        movefile(subject_files(2).filepath, multiple_obs_dir);
        
        disp(['Averaged files for subject ' subject_id ' and saved to ' new_filename]);
    elseif length(subject_files) > 2
        % Move all files to the multiple_observations directory
        for j = 1:length(subject_files)
            movefile(subject_files(j).filepath, multiple_obs_dir);
        end
        warning(['Subject ' subject_id ' has more than 2 scans. Moved to multiple_observations.']);
    else
        % Only one scan, move to patients or controls directory
        movefile(subject_files(1).filepath, fullfile(group_dir, subject_files(1).name));
        disp(['Moved single scan for subject ' subject_id ' to ' group_dir]);
    end
end