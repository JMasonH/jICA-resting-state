#!/bin/bash

# Define the directory paths
base_dir="/fs1/neurdylab/projects/jICA/test_pipe/jICA-neuroimaging-epilepsy/single_subject_jICA_projections"
controls_dir="${base_dir}/controls"
patients_dir="${base_dir}/patients"

# Create directories if they don't already exist
if [ ! -d "$controls_dir" ]; then
    mkdir -p "$controls_dir"
fi

if [ ! -d "$patients_dir" ]; then
    mkdir -p "$patients_dir"
fi


# Move files starting with 'vcon' to the controls directory
for file in "${base_dir}"/vcon*; do
    if [ -f "$file" ]; then  # Check if it's a file
        mv "$file" "$controls_dir"
        echo "Moved $file to $controls_dir"
    fi
done

# Move files starting with 'vpat' to the patients directory
for file in "${base_dir}"/vpat*; do
    if [ -f "$file" ]; then  # Check if it's a file
        mv "$file" "$patients_dir"
        echo "Moved $file to $patients_dir"
    fi
done

echo "File organization complete."

