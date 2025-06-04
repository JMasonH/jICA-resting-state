addpath(fastica_path); 
addpath(icasso_path); 

if ~exist(fullfile(workDir, 'group_jICA_results'), 'dir')
    mkdir(fullfile(workDir, 'group_jICA_results'));
end

dataDir = fullfile(workDir, 'pre_jICA_data'); 


List = dir(fullfile(dataDir, '*.mat'));
band_labels = {'delta','theta','alpha','beta','gamma'};

pathsToAdd = {fastica_path, icasso_path};

addpathFcn = @() cellfun(@(p) addpath(p), pathsToAdd, 'UniformOutput', false);
q = parallel.pool.Constant(addpathFcn);

for band = 1:length(band_labels)

    input = zeros(66, 575*length(List));

    for fileIdx = 1:length(List)

        filePath = fullfile(List(fileIdx).folder, List(fileIdx).name);
        data = load(filePath);
        subset_data = data.OUT.joint_data([1:26, 28:67], :, band);
        transposed_data = transpose(subset_data);

        joint_data = zscore(data.OUT.joint_data([1:26, 28:67], :, band));
        input(:, 575*(fileIdx-1)+1:575*fileIdx) = joint_data;
    end
    
    [coeff,score,latent,tsquared,explained] = pca(transpose(input));

    total_variance = sum(var(input, 0, 2));

    n_icasso = 50; % number of ICASSO cycles
    k_all = 2:30; % loop over number of ICA components


    parfor k_0 = 1:length(k_all)
       
        q.Value();

        k = k_all(k_0);
        [Iq, A, W, S, struc_R] = icasso(input, n_icasso, 'approach','symm','g','tanh','lastEig',k,'maxNumIterations',2e4,'epsilon',1e-5,'vis', 'off');
        v = length(find(Iq > 0.5)); % 0.5 cutoff for assigning components that are reproducible
        v_all(k_0) = v;
        Iq_all{k_0,1} = Iq;
        Ai_all{k_0,1} = A;

        G = A*S;
        var_explained = sum(var(G, 0, 2)) / total_variance; % variance explained by k components
        var_expl_all(k_0) = var_explained; % store the variance explained for each k
    end


    vi_all = v_all./k_all; % proportion of reproducible components
    [vi_opt, ind_opt] = max(vi_all); % find optimal number of components based on proportion of reproducible components
    k_opt = k_all(ind_opt);
    Ainit = Ai_all{ind_opt};
    [icasig,A,B] = fastica(input,'approach','symm','g','tanh','lastEig',k_opt,'maxNumIterations',2e4,'epsilon',1e-5,'initGuess',Ainit);
    
    
    vi_all_storage{band} = vi_all;
    k_opt_storage(band) = k_opt;

    

    % combine both plots:
    figure;
    yyaxis left;
    plot(k_all, vi_all, 'o-', 'LineWidth', 2);
    ylabel('Proportion of Reproducible Components');
    yyaxis right;
    plot(k_all, var_expl_all, 's-', 'LineWidth', 2);
    xlabel('Number of Components (k)');
    ylabel('Variance Explained (%)');
    title(['Reproducibility & Variance Explained - ', band_labels{band}]);
    grid on;
    saveas(gcf, fullfile('./', [band_labels{band}, 'jica_elbow_plot.png']));
    
    close(gcf);
 
    newFilePath = fullfile(workDir, 'group_jICA_results', [band_labels{band}, '-jica_full', '.mat']);
    OUT.icasig = icasig;
    OUT.A = A;
    OUT.B = B;
    OUT.vi_all = vi_all;
    OUT.Ai_all = Ai_all;
    OUT.Iq_all = Iq_all;
    OUT.coeff = coeff;
    OUT.score = score; 
    OUT.explained = explained;
    save(newFilePath, 'OUT'); 
  
end

delete(pool);
