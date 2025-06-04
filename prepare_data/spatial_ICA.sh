#!/bin/bash

# Check that both arguments were provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_txt_path> <output_dir>"
  exit 1
fi

input_file=$1
output_dir=$2

# Load required modules
module load GCC/5.4.0-2.26 
module load OpenMPI/1.10.3
module load FSL/5.0.10

# Run MELODIC
melodic -i "$input_file" -d 40 -o "$output_dir" --Oorig --report --tr=2.1 -v




