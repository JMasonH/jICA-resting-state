% Define directories
eegDir = fullfile(workDir, 'eeg_data', 'hrf_conv_power');
mriDir = fullfile(workDir, 'fmri_projections');

if ~exist('pre_jICA_data', 'dir')
    mkdir('pre_jICA_data');
end
outputDir = fullfile(workDir, 'pre_jICA_data');

% Get list of EEG and MRI files
eegFiles = dir(fullfile(eegDir, '*.mat'));
mriFiles = dir(fullfile(mriDir, '*.mat'));

% Loop through EEG files
for eegIdx = 1:length(eegFiles)
    eegFilename = eegFiles(eegIdx).name;
    eegFilepath = fullfile(eegDir, eegFilename);
    
    [~, eegFilename, ~] = fileparts(eegFilename);
    commonStr = eegFilename(1:13);
    
    
    % Find corresponding MRI file
    mriFilename = '';
    for mriIdx = 1:length(mriFiles)
        if contains(mriFiles(mriIdx).name, commonStr)
            mriFilename = mriFiles(mriIdx).name;
            break;
        end
    end
    
    if isempty(mriFilename)
        continue; % skip if no corresponding MRI file found
    end
    
    mriFilepath = fullfile(mriDir, mriFilename);
    
    % Load EEG and MRI data
    eegData = load(eegFilepath);
    mriData = load(mriFilepath);
    
    % Extract relevant fields
    BLP_conv = eegData.OUT.BLP_conv; % 5x575x26
   
    time_series = mriData.OUT.time_series;% 41x575

    if size(BLP_conv, 2) ~= 575 || size(time_series, 2) ~= 575
        disp(['Skipping due to mismatched time points: ' eegFilename ' and ' mriFilename]);
        continue; % skip if time points do not match
    end

    
    % Repeat MRI data along the frequency band dimension
    time_series_repeated = repmat(time_series, 1, 1, 5);% 41x575x5
    
    % Permute the MRI data to match the EEG data dimensions
    time_series_repeated = permute(time_series_repeated, [3, 2, 1]); % 5x575x41
    
    % Concatenate along the third dimension (signal sources)
    joint_data = cat(3, BLP_conv, time_series_repeated); % 5x575x67
    
    % Permute the result to the final desired shape (67x575x5)
    joint_data = permute(joint_data, [3, 2, 1]); % 67x575x5

    if commonStr(1:4) == 'vpat'
        joint_data(68, :, :) = 1; % add a dummy variable for the group
    elseif commonStr(1:4) == 'vcon'
        joint_data(68, :, :) = 0; % add a dummy variable for the group
    end 
    
    % Save the joint data
    outputFilename = [commonStr '_joint_data.mat'];
    outputFilepath = fullfile(outputDir, outputFilename);
    OUT.joint_data = joint_data;
    save(outputFilepath, 'OUT');
    
    disp(['Saved: ' outputFilepath]);
end
