#!/bin/bash

module load GCC/8.2.0
module load OpenMPI/3.1.4
module load FSL/6.0.1

# Arguments passed from MATLAB
INPUT_DIR="$1"
OUTPUT_DIR="$2"
DESIGN_MAT="$3"
DESIGN_CON="$4"
MASK="$5"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to perform randomise t-test
foo() {
    local comp_num="$1"
    local input_file="${INPUT_DIR}/comp_${comp_num}_4D.nii.gz"
    local output_prefix="${OUTPUT_DIR}/comp_${comp_num}"

    echo "Processing comp_${comp_num}"

    tmp_dir=$(mktemp -d -t randomise-XXXXXXXX)
    mkdir -p "$tmp_dir/INPUTS" "$tmp_dir/OUTPUTS"

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file $input_file not found"
        rm -rf "$tmp_dir"
        return 1
    fi

    cp "$input_file" "$tmp_dir/INPUTS/"

    randomise -i "$tmp_dir/INPUTS/comp_${comp_num}_4D.nii.gz" \
              -o "$tmp_dir/OUTPUTS/comp_${comp_num}" \
              -d "$DESIGN_MAT" \
              -t "$DESIGN_CON" \
              -m "$MASK" \
              -x -c 2.3 -n 5000 \
              -T

    cp "$tmp_dir/OUTPUTS/comp_${comp_num}"* "$OUTPUT_DIR/"
    rm -rf "$tmp_dir"

    echo "Completed t-test for comp_${comp_num}"
}

export -f foo

# Parallel processing
N=8
(
for comp_num in {1..80}; do
    ((i=i%N)); ((i++==0)) && wait
    foo "$comp_num" &
done
wait
)

echo "All t-tests completed"
