function OUT = eeg_power_ts(input_txt_file)
    % Create directory structure
    if ~exist('eeg_data', 'dir')
        mkdir('eeg_data');
    end
    if ~exist('eeg_data/raw_power', 'dir')
        mkdir('eeg_data/raw_power');
    end
    if ~exist('eeg_data/hrf_conv_power', 'dir')
        mkdir('eeg_data/hrf_conv_power');
    end
    
    % Open the file
    fid = fopen(input_txt_file, 'r');
    
    % Read the file paths into a cell array
    filePaths = textscan(fid, '%s', 'Delimiter', '\n');
    
    % Close the file
    fclose(fid);
    
    % Convert filePaths to a simple cell array of strings
    filePaths = filePaths{1};
    
    % Loop through each entry in the file paths array
    for i = 1:length(filePaths)
        [~, filename, ~] = fileparts(filePaths{i});  % Extract filename without extension
        
        basename = filename(1:13);
        
        % Load the data from the file specified in the array
        data = load(filePaths{i});  % Ensure filePaths contains file names as strings
        
        buff = data.frames_bufferOv;
        
        % Check if the data contains the 'EEG' struct
        if isfield(data, 'EEG')
            EEG = data.EEG;
            fprintf('Loaded EEG struct from file: %s\n', filePaths{i});
            
            % Check if 'srate' field exists in the EEG struct
            if isfield(EEG, 'srate')
                fprintf('EEG.srate found: %f\n', EEG.srate);
                
                % Get the 'times' field from the 'EEG' struct
                frames = [EEG.event(strcmp({EEG.event.type}, 'R149')).latency];
                
                chans_use = {EEG.chanlocs(1:26).labels};
                
                % Create output filename with path
                output_filename = fullfile('eeg_data', 'raw_power', [basename, 'power.mat']);
                
                % Call the make_eeg_regressors_vu function with the appropriate parameters
                make_eeg_regressors(EEG, chans_use, length(frames), 2.1, output_filename, [], buff);
            else
                error('EEG.srate field is missing in file: %s\n', filePaths{i});
            end
        else
            error('EEG struct is missing in file: %s\n', filePaths{i});
        end
    end
end