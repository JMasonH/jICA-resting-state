function [signal_conv] = ...
    conv_hrf(signal_values)
% CORRELATE_SIGNAL_FMRI creates a signal correlation volume and signal beta
% volume based on the fmri and signal input. Signal input is the metric
% being used to correlate with the fmri
    % 
    % dims = size(mask);
    % mask_inds = find(mask ~= 0);
    % t = (1:size(Y, 1))';
    % T = [t, t.^2, t.^3, t.^4];
    % 
    % if nargin < 7
    %     figs = true;
    % end
    
    signal_pow = signal_values(:)'; % ensures a row vector
    % reassigning NaN values to the first nonNaN value
    signal_pow(isnan(signal_pow)) = signal_pow(find(~isnan(signal_pow), 1));
%     signal_conv0 = conv(signal_pow - nanmean(signal_pow), spm_hrf(2.1)); % changed to nanmean
    signal_conv0 = conv(signal_pow - mean(signal_pow), spm_hrf(2.1));
    signal_conv = signal_conv0(1:length(signal_pow));

    % METHOD #1:
    % remove artifact signals from fMRI data, and then look at
    % correlation between eeg and fMRI

    % regressors = zscore([motions, T]);
    % X = appendOnes(regressors);
    % betas = pinv(X) * Y;
    % Y_clean = Y - X(:, 2:end) * betas(2:end, :);
    % 
    % signal_correlation_vec = corr(signal_conv', Y_clean, 'rows', 'complete');
    % signal_correlation_vol = zeros(dims(:)');
    % signal_correlation_vol(mask_inds) = signal_correlation_vec;
    
    % METHOD #2:
    % % simultaneous regression model
    % 
    % regressors = nanzscore([signal_conv', motions, T]); % changed to "nanzscore" (see custom function)
    % X = appendOnes(regressors);
    % betas = pinv(X) * zscore(Y);
    % 
    % signal_betas_vol = zeros(dims(:)');
    % signal_betas_vol(mask_inds) = betas(2, :);
    % 
    % if figs
    %     slices_to_show = 20:2:80;
    %     close(figure(1), figure(2));
    %     set(figure(1), 'Name', append(signal_label, ' [Correlations]'), ...
    %         'Visible', 'off');
    %     slmontage_mni(signal_correlation_vol, slices_to_show, C);
    %     set(figure(2), 'Name', append(signal_label, ' [Betas]'), ...
    %         'Visible', 'off');
    %     slmontage_mni(signal_betas_vol, slices_to_show, C);
    % end
end
