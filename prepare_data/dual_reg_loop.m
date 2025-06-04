%DUAL REGRESSION CODE
function OUT = dual_reg_loop(input_txt_file, workDir, maskPath)

    if ~exist('fmri_projections', 'dir')
        mkdir('fmri_projections');
    end
  
    % Open the file
    fid = fopen(input_txt_file, 'r');
    
    % Read the file paths into a cell array
    filePaths = textscan(fid, '%s', 'Delimiter', '\n');
    
    % Close the file
    fclose(fid);
    
    % Convert filePaths to a simple cell array of strings
    filePaths = filePaths{1};
    
    nii_file = dir(fullfile(workDir, '**', 'melodic_IC.nii.gz'));
    if isempty(nii_file)
        error('Could not find melodic_IC.nii.gz in %s or subdirectories.', workDir);
    end
    ICA_components = niftiread(fullfile(nii_file(1).folder, nii_file(1).name));
    mask = niftiread(maskPath);

    % Loop through each entry in the file paths array
    
   for i = 1:length(filePaths)

       Y=niftiread(filePaths{i});

        dims = size(Y);

        newY = reshape(Y,prod(dims(1:3)),size(Y,4));

        vox = find(mask>0);

        maskedY = newY(vox,:);
        
        component1 = ICA_components(:,:,:,1);
        
        maskedComponent1 = component1(vox);
        
        ICA_spatial_maps_voxels = zeros(size(maskedComponent1,1),size(ICA_components,4));
        
        for j = 1:size(ICA_components,4)
            component = ICA_components(:,:,:,j);
            maskedComponent = component(vox);
            ICA_spatial_maps_voxels(:,j) = [maskedComponent];
        end
        
        X=[ones(size(ICA_spatial_maps_voxels,1),1), zscore(ICA_spatial_maps_voxels)];
        
        %derive subject specific time course
        beta_1= pinv(X)*maskedY;
        beta_1_z = zscore(beta_1);
        
        %label subject specific ts as the next X to derive spatial map
        x_ts=beta_1(2:41,:);
        
        x_ts=[ones(size(x_ts,2),1),zscore(transpose(x_ts))];
        
        %derive subject specific spatial maps
        beta_2= pinv(x_ts)*transpose(maskedY);

        [~, fileName] = fileparts(filePaths{i});
        basename = fileName(1:13);
        newFilePath = fullfile('fmri_projections', [basename, '_IC_reg', '.mat']);
        OUT.spatial = beta_2;
        OUT.time_series = beta_1;
        save(newFilePath, 'OUT'); 
        fprintf('Completed %d/%d\n', i, length(filePaths));
   end
end   



