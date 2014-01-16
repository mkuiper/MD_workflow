#!/bin/bash

# simple script to reinitialize all jobs for a new round in the MainJob_dir directory. 
#---------------------------------

# source common functions: 
source Scripts/common_functions.sh

# check for master_config_file:
read_master_config_file Setup_and_Config 

# --Check for existing directories: 
check_directory_list . 

y=$(cat .dir_list.txt) 

# -create job_submit_list to record sbatch job_ids.  (useful for cancelling jobs stuck in the queue). 
r=$round
echo -e "Current simulation round set to: $round \n" 
echo -e "Make sure to change round value in Setup_and_Config/master_master_config_file" 
echo -e "and propagate to job directories with ./populate_config_files.sh" 

echo -e "\n\nChecking that all current round jobs are finished:" 

# make quick copy of showq for checking
host=$(echo $HOSTNAME) 
if [ $host = "avoca" ] || [ $host = "merri" ] || [ $host = "barcoo" ]; then
 echo -e " on $host: " 
 make_temp_showq_list
 else 
 echo -e "\n-not on system, can't make temporary showq list! \n"  
fi


# - Reset job directories:
cd $JOB_DIR

for i in $y
do

# launch jobs in MainJob_dir:---------------------------------------------------------
cd $i

# check first for running jobs and that all jobs have finished: 

check_for_running_job 
check_for_zero_countdown

if [ "$js" == "RUNNING" ]; then
 echo -e " Job still appears to be running in $i  :jobid: $j" 
 echo -e " Can't reinitialize new production rounds till all jobs finished. \n exiting." 
 exit
fi 

cd ../

done

# if made it this far, all clear to reinitialize job folders:
for i in $y
do
 cd $i 

# read local master_config_file:
 read_master_config_file . 

# copy last restart files:
 cp LastRestart/* . 

# reset .countdown.txt 
 echo $runs > .countdown.txt


 cd ../

done

 echo -e "\n Job directories reinitialized for new production round." 
 echo -e "\n Use './restart_all_production_jobs.sh' to start and continue jobs." 

exit

