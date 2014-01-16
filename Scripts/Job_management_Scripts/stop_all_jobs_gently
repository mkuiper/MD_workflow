#!/bin/bash

# Script to stop all jobs gently in the MainJob_dir directory. 
# by allowing them to finish their current job. 
# (creates a pausejob file) 
#---------------------------------

source Scripts/common_functions.sh

# Check for existing directories: 
read_master_config_file Setup_and_Config

# Check for directory list:
check_directory_list . 
y=$(cat .dir_list.txt) 

echo -e "\n Jobs stopping.  \n Simulations currently running in $JOB_DIR will be allowed to finish: \n" 
sleep 2

cd $JOB_DIR

for i in $y
# pause jobs in MainJob_dir
do
 cd $i
# -- create pause flag:  (this is looked for in the sbatch scripts) 
 touch pausejob
 echo -e " Asked job to pause in directory $JOB_DIR/$i  "
 echo -e "M:SetToPause" >.job_status
 cd ../
 sleep 0.05
done


