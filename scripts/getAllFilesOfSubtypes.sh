#!/bin/bash
#This script runs a simple find command to generate a list of all files of the subtypes desired
#it writes the list to the desired output location
set -eou pipefail

#########################Set Key Variables#######################################
startDir="/mnt/mobydisk/pan/genomics/data/alee"
outputFile="/mnt/mobydisk/pan/genomics/data/alee/dataUseManagment/outputs/2019-02-06/findFaFqBamOutput_06022019.txt"


find "${startDir}" -type f \( -name "*.fq" -o -name "*.bam" -o -iname "*.fa" \) >"${outputFile}"


