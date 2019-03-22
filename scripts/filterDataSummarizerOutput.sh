#!/bin/bash
#simple script filters output of dataUseSummarizer.sh by size using awk
set -e
set -u
set -o pipefail

#-------------------------------------------------------
#Define key variables
filterCutoff=1000000 #the size cutoff for our filterer in bytes

#-------------------------------------------------------

awk '{if ($3 >= "${filterCutoff}") { print } } ' "${1}" 

echo 'Filtered '"${1}"' using '"${filterCutoff}"'byte filesize cutoff'

