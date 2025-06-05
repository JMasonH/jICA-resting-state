% Open the file

    path_dir = fullfile(workDir, 'pre_jICA_data');
    mm_dir = fullfile(workDir, 'group_jICA_results');

    if ~exist(fullfile(workDir, 'single_subject_jICA_projections'), 'dir')
        mkdir(fullfile(workDir, 'single_subject_jICA_projections'));
    end

    sub_files = dir(fullfile(path_dir, '*.mat'));
    jica_files = dir(fullfile(mm_dir, '*.mat'));

    hold_name = fullfile(mm_dir, jica_files(1).name);
    hold = load(hold_name); 
    [row, col] = size(hold.OUT.A);
        
    % Loop through each entry in the file paths array
    for i = 1:length(sub_files)

        time_series = zeros(col, 575, 5);
        spatial = zeros(col, 66, 5);

        file_name = fullfile(path_dir, sub_files(i).name);
        Yraw = load(file_name);
        Ymat = Yraw.OUT.joint_data;

        for j = 1:length(jica_files)
            
            mm_name = fullfile(mm_dir, jica_files(j).name);
            [~, base_name, ext] = fileparts(mm_name);  % Extract file name without path
            full_name = [base_name, ext];  % Combine base name with extension
    
             % Check the file name and assign the correct Y matrix
             if strcmp(full_name, 'delta-jica_full.mat')
                 Y = Ymat([1:26, 28:67], :, 1);
                 b = 1;
             elseif strcmp(full_name, 'theta-jica_full.mat')
                 Y = Ymat([1:26, 28:67], :, 2);
                 b = 2;
             elseif strcmp(full_name, 'alpha-jica_full.mat')
                 Y = Ymat([1:26, 28:67], :, 3);
                 b = 3;
             elseif strcmp(full_name, 'beta-jica_full.mat')
                 Y = Ymat([1:26, 28:67], :, 4);
                 b = 4;
            elseif strcmp(full_name, 'gamma-jica_full.mat')
                 Y = Ymat([1:26, 28:67], :, 5);
                 b = 5;
            else
            error('Unrecognized file name: %s', full_name);  % Add error handling for unexpected cases
            end
            
            mm = load(mm_name);
            Xmat = mm.OUT.A;
        
             % Derive subject-specific time course (temporal regression)
            X = [ones(size(Xmat, 1), 1), Xmat];
            beta_1 = pinv(X) * Y;
             %beta_1_z = zscore(beta_1);
            time_series(:,:,b) = beta_1(2:end, :);
        
             % Derive subject-specific spatial maps (spatial regression)
            x_ts = beta_1(2:end, :);  % Use components time series (exclude intercept)
            x_ts = [ones(size(x_ts, 2), 1), zscore(transpose(x_ts))];  % Regress over time
            beta_2 = pinv(x_ts) * transpose(Y);  % Get spatial maps
            spatial(:, :, b) = beta_2(2:end, :);

        end
        % Save results
        n = 13;  % Specify the number of characters to keep
        [~, fileName] = fileparts(sub_files(i).name);

       
        if length(fileName) > n
            fileName = fileName(1:n);
        end

        newFilePath = fullfile(workDir, 'single_subject_jICA_projections/', [fileName, '_jICA', '.mat']);
        OUT.spatial = spatial;
        OUT.time_series = time_series;
        save(newFilePath, 'OUT'); 
        fprintf('Processed subject: %s\n', fileName);
   end


