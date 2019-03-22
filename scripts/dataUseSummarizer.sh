#!/bin/bash
set e
set u
set o pipefail


#this script generates a summary of disk use in a target directory by user, assuming the user's directories are all one below root
#it outputs a tsv record of all files by their full name, disk size, disk size, user and tests if the files are duplicated
#the tsv can be used for further filtering if large or can be immediately read if small
#it also generate a summary of the largest files by user and generates a quick report based on that

#create a named pipes to facilitate Split-Apply-Combine operating on the joined du outputs
mkfifo getBasenameFromJoinedDU.pipe
mkfifo joinedDUOutWithBasename.pipe


targetDirectory="/mnt/mobydisk/pan/genomics/data/alee/"

outputDir="${targetDirectory}""dataUseManagment/outputs/""$(date +%F)"
echo "${outputDir}"

#first generate two lists of files by size with calls to du and merge them on the file ID field with paste -j 2
join -j2 <(du -ah "${targetDirectory}") <(du -a "${targetDirectory}") | \

#do some reformatting to keep everything tab separated
tr "[:blank:]" "\t" | \

#next we tee out the output to extract the basename from the filename in our tsv of filenames and filesizes

#we write the output to a named pipe, getBasenameFromJoinedDU.pipe, to later use in paste
#the raw output of tr is passed over the tee and into paste below
tee >(cut --field 1 | xargs -n 1 basename > getBasenameFromJoinedDU.pipe) | \

#here we combine the basenames from our pipe and paste it onto our tab separated list
#we then sort the list by filenames to feed into AWK

#Here we use awk to combine our TSV of joined DU output with basenames with the results of fslinter's findup command
#we use AWK's ability to process multiple records by using the AWK variables NR (which equals total number records read)
#and FNR(which specifies the record number for the current file)
#On the first file, where NR=FNR, we record the value of the first element of each record in an array indexed by that value c[$1]=$1
#subsequenly we move on to the later record and test if the value of the second record is contained in the findup outputs
#This ultimately generates our Duplicate column
paste - getBasenameFromJoinedDU.pipe | sort -k 1 | \
awk  'BEGIN {}; NR==FNR{c[$1]=$1; next} {print $0, (c[$1]==$1?"TRUE":"FALSE") }' \
<(/ihome/sam/apps/fslint/fslint-2.46/fslint/findup "${targetDirectory}" | sed "s_^_${targetDirectory}/_" | sort -k 1) - | \

#our awk inputs are specified by command substitution and piping
#we command substitute our findup call and append the full directory name to the findup output with sed
#finally we sort that input and pass the pipe input with '-'

#we next use gawk for its regex utilities to extract the username from our tFilepath
#this function depends on the script being run on htc and all usernames sitting directly under the PI Directory
awk 'BEGIN{print "Filename\tFileSizeHuman\tFileSizeBytes\tUser\tDuplicated?\tFilepath"} {userName=gensub(/.*?\/data\/alee\/(\w*?)\/.*?/, "\\1", "g"); print $4,$2,$3,userName,$5,$1}' | \
#final tr to ensure it really is a TSV
tr "[:blank:]" "\t" | \

#we then generate two full size list outputs, one sorted by size, one sorted by user then size
tee >((head -n 1 && tail -n +2 | sort -nrk3) >"${outputDir}""/fullFileSummarySortedBySize.tsv") | \

(head -n 1 && tail -n +2 | sort -k4,4 -nrk3,3) >"${outputDir}""/fullFileSummarySortedByUserAndSize.tsv"

#finally we remove the named pipes we generated in running this script
rm getBasenameFromJoinedDU.pipe
rm joinedDUOutWithBasename.pipe
