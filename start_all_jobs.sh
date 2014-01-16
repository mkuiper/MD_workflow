#!/bin/bash

# simple script to start all jobs in the MainJob_dir directory. 
#---------------------------------

source Scripts/common_functions.sh
# check for master_config_file:
read_master_config_file Setup_and_Config


# --Check for existing directories: 
check_directory_list . 

y=$(cat .dir_list.txt) 

# -create job_submit_list to record sbatch job_ids.  (useful for cancelling jobs stuck in the queue). 

echo -e "" > .job_submit_list.txt

# make quick copy of showq for checking
make_temp_showq_list

# - Launch Jobs: 
cd $JOB_DIR

for i in $y
do

# launch jobs in MainJob_dir:---------------------------------------------------------
cd $i

# check if job is already running: 
 if [ -f .current_job_id.txt ];
 then
# -if current job_id flag detected:

 j=$(cat .current_job_id.txt | tail -n 1 )
 e=$(cat ../../.temp_showq.txt  |grep $j | awk '{print $3 }');
 if [ "$e" == "RUNNING" ];
 then
  echo -e " $i - appears a job is already running here!: $j" 
 else
  if [ -f pausejob ]; 
  then
   rm pausejob
  fi

sbatch $sbatch_start | awk '{ print $4 }' >> ../../.job_submit_list.txt
echo -e " Launching job in directory $JOB_DIR/$i "
echo -e "job launched">.job_status

  fi
 else

# - if no current job_id flag detected:
   if [ -f pausejob ]; then
    rm pausejob
   fi

sbatch $sbatch_start | awk '{ print $4 }' >> ../../.job_submit_list.txt
echo -e " Launching job in directory $JOB_DIR/$i "
echo -e "job launched">.job_status

  fi

cd ../

# - a little pause to help the scheduler: 
sleep 0.05
done

exit

