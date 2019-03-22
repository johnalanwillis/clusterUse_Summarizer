#!/bin/bash
# a jobscript for slurm submission from DUSummarizer

################# variables for job submission #####################
nodes=1
ppn=2

#each job is named for its 
jobName="dataUseSummarizer""$(date +%F)"

jobTime="$(date +%F)"
#our outputs are sent to a dated direcotry
mkdir "../outputs/""${jobTime}""/"

#we write our base dataUseSummarizer.sh script to a job specific script with cat
cd ../outputs/"${jobTime}"
cat ../../scripts/dataUseSummarizer.sh >"${jobName}"".job.sbatch"

sbatch -N $nodes --cpus-per-task $ppn --mem=16g -J "${jobName}"".job" \
-e "${jobName}"".job.err" -o  "${jobName}"".job.out"  \
-t 3-00:00 "${jobName}"".job.sbatch"
