#!/bin/bash

# Script to stop all jobs immediately in the MainJob_dir directory. 
#   (runs scancel on their job id) 
#---------------------------------

source Scripts/common_functions.sh

# Check for existing directories: 
read_master_config_file Setup_and_Config

# Check for direcory list: 
check_directory_list .
y=$(cat .dir_list.txt) 

echo -e "\n Jobs stopping.  \n Simulations currently running in $JOB_DIR will be terminated: \n" 
sleep 1
 
cd $JOB_DIR

# --find current_job_id in each job directory and send scancel command:
for i in $y
do

 cd $i

 if [ -f .current_job_id.txt ];
  then
   j=$(cat .current_job_id.txt | tail -n 1  )

   scancel $j
   echo -e " Sent scancel command for job id  $j in directory $JOB_DIR/$i "
   echo -e "M:terminated " >.job_status
  else
   echo -e " No job appears to be running in directory $JOB_DIR/$i"
 fi   

  cd ../
  sleep 0.05
done



