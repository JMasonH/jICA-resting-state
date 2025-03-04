#!/bin/bash


input_dir="./group_jICA_results/group_component_maps/fmri"

output_dir="./group_jICA_results/group_component_maps/fmri"

mni_template="/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/MNI152_T1_2mm_brain.nii.gz"


mkdir -p "$output_dir"


for nifti_file in "$input_dir"/jICA_fmri_*.nii; do
    
    base_filename=$(basename "$nifti_file" .nii)

    
    file_number=$(echo "$base_filename" | grep -oP '(?<=jICA_fmri_)\d+')

   
    if [ -z "$file_number" ]; then
        echo "Warning: No number found in filename $nifti_file. Skipping file."
        continue
    fi

    echo "Processing file: $nifti_file"
    echo "Extracted file number: $file_number"

    3drefit -view orig -space ORIG "$mni_template"

    
    @chauffeur_afni                                                       \
        -ulay "$mni_template"                                             \
        -olay "$nifti_file"                                               \
        -prefix "${output_dir}/jICA_${file_number}"                       \
        -montx 4 -monty 4                                                 \
        -delta_slices 3 3 3                                               \
        -set_xhairs OFF                                                   \
        -no_cor                                                           \
        -do_clean                                                         \
        -box_focus_slices AMASK_FOCUS_ULAY                                \
        -cbar GoogleTurbo
   done

echo "Processing complete. All images saved to $output_dir"
