

dataDir = '/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/group_jICA_results/';
new_dir = '/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/spectral_analysis/';


if ~exist(new_dir, 'dir')
    mkdir(new_dir);
end

List = dir(fullfile(dataDir, '*.mat'));

if isempty(List)
    error('No .mat files found in the specified directory: %s', dataDir);
else
    disp(['Found ', num2str(length(List)), ' files.']);
end

disp(List);



dummy = load(fullfile(dataDir, List(1).name));
num = height(dummy.OUT.icasig);
scans = (length(dummy.OUT.icasig) / 575);


for d = 1:length(List)

    dat = load(fullfile(dataDir, List(d).name)); 
    timeSeries = dat.OUT.icasig;
    sub_ts = zeros(num, 575, scans); 

    for s = 1:scans
        sub_ts(:, :, s) = timeSeries(:, (575*(s-1)+1):575*s);
    end

    save(fullfile(new_dir, ['sub_spec_', List(d).name,]), 'sub_ts', '-mat');

end


%%

