function OUT = eeg_power_ts(input_txt_file, workDir)
    % Use the parent directory of the input file as the base path

    % Define output directories
    raw_power_dir = fullfile(workDir, 'eeg_data', 'raw_power');
    hrf_power_dir = fullfile(workDir, 'eeg_data', 'hrf_conv_power');

    % Create directory structure if it doesnt exist
    if ~exist(raw_power_dir, 'dir')
        mkdir(raw_power_dir);
    end
    if ~exist(hrf_power_dir, 'dir')
        mkdir(hrf_power_dir);
    end

    % Open and read file paths from the .txt file
    fid = fopen(input_txt_file, 'r');
    filePaths = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    filePaths = filePaths{1};

    % Loop through each entry in the file paths array
    for i = 1:length(filePaths)
        file_path = strtrim(filePaths{i});
        if isempty(file_path)
            continue; % skip empty lines
        end

        [~, filename, ~] = fileparts(file_path);  % Extract filename without extension
        if length(filename) < 13
            warning('Skipping file with short name: %s', file_path);
            continue;
        end
        basename = filename(1:13);

        try
            data = load(file_path);
            buff = data.frames_bufferOv;

            if isfield(data, 'EEG')
                EEG = data.EEG;
                fprintf('Loaded EEG struct from file: %s\n', file_path);

                if isfield(EEG, 'srate')
                    fprintf('EEG.srate found: %f\n', EEG.srate);

                    frames = [EEG.event(strcmp({EEG.event.type}, 'R149')).latency];
                    chans_use = {EEG.chanlocs(1:26).labels};

                    output_filename = fullfile(raw_power_dir, [basename, 'power.mat']);

                    make_eeg_regressors(EEG, chans_use, length(frames), 2.1, output_filename, [], buff);
                else
                    warning('EEG.srate missing in file: %s\n', file_path);
                end
            else
                warning('EEG struct missing in file: %s\n', file_path);
            end
        catch ME
            warning('Failed to process %s: %s\n', file_path, ME.message);
        end
    end
end
