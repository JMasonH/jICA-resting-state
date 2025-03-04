
% Define directories
dir_fmri = '/data/neurogroup/jICA/8_comp_fmri/';
dir_eeg = '/data/neurogroup/jICA/8_comp_eeg/';

% Get list of .mat files from both directories
fmri_files = dir(fullfile(dir_fmri, '*.mat'));
eeg_files = dir(fullfile(dir_eeg, '*.mat'));

% Loop through each file in the fmri directory
for i = 1:length(fmri_files)
    
  
    fmri_file_name = fmri_files(i).name;
    fmri_id = fmri_file_name(1:13);
    
 
    eeg_file_idx = find(arrayfun(@(x) strcmp(fmri_id, x.name(1:13)), eeg_files));
    
  
    if ~isempty(eeg_file_idx)
        
       
        fmri_data = load(fullfile(dir_fmri, fmri_files(i).name));
        eeg_data = load(fullfile(dir_eeg, eeg_files(eeg_file_idx).name));
        
      
        fmri_time_series = fmri_data.OUT.time_series(2:end, :);  % Remove the first row, resulting in 80 x 575
        eeg_time_series = eeg_data.OUT.time_series;              % 80 x 575

        % Check for mismatched time points (columns should be 575)
        if size(fmri_time_series, 2) ~= 575 || size(eeg_time_series, 2) ~= 575
            disp(['Skipping due to mismatched time points: ' fmri_file_name ' and ' eeg_files(eeg_file_idx).name]);
            continue; % Skip this pair of files
        end
        
       
        joint_time_series = zeros(16, 575, 5);
        
        % Loop to concatenate in blocks of 16 rows from both time series
        for j = 1:5
            row_start = (j - 1) * 8 + 1;
            row_end = j * 8;

            joined = cat(1, fmri_time_series(row_start:row_end, :), eeg_time_series(row_start:row_end, :));
            
            % Concatenate the rows for this block
            joint_time_series(:, :, j) = joined;
        end
        
       
        output_file_name = fullfile('/data/neurogroup/jICA/8_joint_ts/', [fmri_id, '_joint_time_series_8.mat']);
        OUT.joint_time_series = joint_time_series;
        save(output_file_name, 'OUT');
        
        fprintf('Processed and saved joint time series for: %s\n', fmri_id);
        
    else
       
        disp(['No matching EEG file found for: ' fmri_file_name]);
    end
end



