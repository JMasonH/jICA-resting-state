#!/bin/bash

module load GCC/5.4.0-2.26 
module load OpenMPI/1.10.3
module load FSL/5.0.10

melodic -i /fs1/neurdylab/projects/jICA/test_pipe/fmri_test_paths.txt -d 40 -o /fs1/neurdylab/projects/jICA/test_pipe --Oorig --report --tr=2.1 -v




