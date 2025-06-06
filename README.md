# Joint ICA for Resting-State fMRI-EEG

This repository contains the code of our ISBI 2025 paper: 
**"Joint Source Decomposition Of Concurrent EEG-fMRI Data in Epilepsy and Control Groups"**

Mason Harding, Haatef Pourmotabbed, Yamin Li, Kimberly Rogge-Obando, Kate Wang, Sarah E. Goodale, Shiyu Wang, Camden Bibro, Bergen Allee, Caroline Martin, Victoria L. Morgan, Dario J. Englot, Catie Chang

## **Requirements**
To run this project, ensure you have **MATLAB Version R2023b or later** installed along with the following toolboxes and external software:

### **MATLAB Toolboxes**
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox
- Signal Processing Toolbox

### **MATLAB Packages**
- [FastICA 2.5](https://research.ics.aalto.fi/ica/fastica/)
- [Icasso 1.22](https://research.ics.aalto.fi/ica/icasso/about+download.shtml)
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
- [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)

### **External Software**
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki) (for spatial ICA, pairwise statistical testing, and merging data into group nifti files)
- [AFNI](https://afni.nimh.nih.gov/) (for visualization)

### Prepare Data
**EEG:** Current code uses a '.txt' file containing file paths to each individual scan's EEG file. EEG was preprocessed for removal of MRI gradient and ballistocardiogram artifacts using BrainVision Analyzer, after which it was downsampled to 250 Hz. ECG, EOG, EMG electrodes were excluded from the analysis, leaving 26 EEG electrodes.

**fMRI:** Similarly, initial fMRI data is provided to the analysis code as a '.txt' file containing file paths to each individual gunzipped '.nii' scan file. Following slice-timing correction and motion coregistration, multi-echo ICA was implemented to mitigate non-BOLD artifacts, and the fMRI data were spatially normalized to MNI152 standard space.


  







