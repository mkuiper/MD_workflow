#!/bin/bash
##  sbatch launching script                          Jan  2013  MKuiper
## -A generic script to launch a series of production namd runs
## on the Avoca bluegene cluster at vlsci. 

#--------------------------------------------------------------- 
#                                                              #
#         Make all changes in "master_config_file"             #
#                                                              #
#     -you shouldn't have to change anything in here!          #
#---------------------------------------------------------------

#-- Sbatch parameters:------------------------------------------
#-- the X values will be substituted with a values from the master_config_file 
#-- use "./populate_config_files" to populate job directories with input files.   

#PBS -l nodes=X:ppn=8
#PBS -l walltime=X
#PBS -A account=X

# ntpn=X         # number of tasks per node: 
# ppn=X          # processors per node: 
module load X  # module file:

#-- Read variables from master_config_file:
if [ -f master_config_file ]
 then
 . master_config_file
else
 echo -e " Doesn't appear to be a master_config_file in this directory! Exiting."   
 echo -e "P:NoMasterConfig" >.job_status
 exit
fi

jobname=$jobname_prod
## -- slurm file cleanup: ------------------
if [ -f .old_pbs_file ]; then 
 slm=$(cat .old_pbs_file | tail -n 1  ) 
 mv $slm JobLog/
fi
ls pbs-* > .old_pbs_file   

## --check for pausejob flag:----------------------------------------------------------- 
if [ -f pausejob ]; then
 echo -e " Pausejob flag present: Perhaps last job failed? Exiting."  
 echo -e "P:Paused">.job_status
 exit 
fi 

##  -- check disk quota before starting job! : stop job if too close: ------------------  
diskspace=$( mydisk | grep $account | awk '{print $5}' | sed s/\%// )  
if [ "$diskspace" -gt $diskspacecutoff ]; then 
 echo -e " Warning: diskspace for this account is low! Check disk quotas  (mydisk)  " 
 echo -e " Clean up your files! Exiting. " 
 echo -e "P:DiskQuotaFull" >.job_status
 touch pausejob
 exit 
fi 

### - read job countdowntimer: stop if .countdown.txt <=0 ----------------------------

if [ -f .countdown.txt ];
then  
 y=$(cat .countdown.txt )
else 
 echo -e " Countdown file not found (.countdown.txt).  Exiting." 
 echo -e "P:NoCountdownFlag" >.job_status
 touch pausejob
 exit 
fi  

if [ $y -lt 1 ]; then
 echo -e " Job countdown less than 1. Consecutive jobs finished! Exiting." 
 echo -e "P:Finished" >.job_status  
 exit 
fi

## -- job fail safe check timestamp: - (to stop job if it completes in less than a specified time: --
jfc1=$(date +%s);                   # jobfailcheck time stamp1
date=$(date +%F);                   # date stamps
date2=$(date +%F-%H.%M);            # date stamps
basename="$date2.$jobname_prod.$y";  # create timestamped basename for production run

echo $PBS_JOBID >.current_job_id.txt;
qstat -f $PBS_JOBID >>JobLog/$date2.$jobname_prod.$y.txt; # log job details

# -- launching job for avoca: -----------------------------------------------------------------------
echo -e "P:Running" >.job_status

mpirun namd2  $production_script >OutputText/$basename.opt 2>Errors/$basename.err;

# +ppn is for smp version only. 
# smp version:
#srun  --ntasks-per-node $ntpn  namd2 +ppn $ppn $production_script >OutputText/$basename.out 2>Errors/$basename.err;
# pmi version:
#srun  --ntasks-per-node $ntpn  namd2 $production_script >OutputText/$basename.out 2>Errors/$basename.err;

echo -e "P:CleaningUp" >.job_status

### -- after the job has finished: ------------------------------------------------------------------ 
jfc2=$(date +%s);                                                   # jobfailcheck time stamp2
let runtime=$jfc2-$jfc1;                                             # job run time.               
jobhours=$(echo $runtime | awk '{printf "%.3f hours", $1/3600}');  
timing=$(../../Scripts/Tools/timing_data_miner OutputText/$basename.out); # mine timing data
echo $basename  $jobhours  $timing  >>JobLog/timing_data_log.txt;    # log timing data

## -- Job fail check: kill job if runtime less than specified time:-----------------------------
if [ $runtime -lt $jobfailtime ]; 
 then
## -- log failed job tj=$(cat .jobdir_id );
 j=$(cat .jobdir_id );
 c=$(cat .current_job_id.txt);
 date2=$(date +%F-%H.%M);
 echo -e "$j $c failed at $date2 at stage $y " >> ../../JobLog/Failed_job_list.txt
 echo -e "P:JobFinishedEarly:Crash?" >.job_status
 touch pausejob;                 # create pause flag 
 exit
fi

### -- Rename output and move data into respective folders: ----------------------------------------- 
for f in generic_restartfile*
do
 case $f in 
  *.dcd)  mv $f OutputFiles/$basename.dcd;;
  *.coor) cp $f RestartFiles/$basename.coor; cp $f LastRestart/;;
  *.vel)  cp $f RestartFiles/$basename.vel;  cp $f LastRestart/;;
  *.xsc)  cp $f RestartFiles/$basename.xsc;  cp $f LastRestart/;;
  *.xst)  cp $f RestartFiles/$basename.xst;;
  *.colvars.state) cp $f RestartFiles/$basename.colvars.state;;
  *.colvars.traj)  cp $f RestartFiles/$basename.colvars.traj;;
 esac 
done

## - add the dcd file name to a dcdlist for later processing: -------------------------
echo $basename.dcd >>OutputFiles/dcd_list.txt 
rm *.BAK  *.old;                 # clean up files

## -- adjust countdowntimer:-----------------------------------------------------------
let y=$y-1;
echo $y>.countdown.txt;

## -- Just finished final job?  Check countdown timer:-------------------------------------------- 
if [ $y -lt 1 ]; 
then 
## -- Cleanup directory at completion of final production run:
 mv FFTW* OutputText/;
 rm *.BAK *.old *.coor *.vel *.xsc *.xst *.state *.traj; 
 mv pbs_*.e* Errors/;
 mv pbs_*.o* JobLog/;
 mv slurm-*  JobLog/;
 mv core*    Errors/;
 echo -e "P:Finshed" >.job_status

## -- create a dcd file loader .vmd file in /OutputFiles 
 cd OutputFiles
  ../../../Scripts/Tools/create_dcd_loader_script
 cd ../

## -- log finished job details to ../../JobLog/Finished_job_list.txt
 j=$(cat .jobdir_id )
 c=$(cat .current_job_id.txt) 
 date2=$(date +%F-%H.%M);
 echo -e "$j $c finished at $date2 " >> ../../JobLog/Finished_job_list.txt 
 exit
fi

## -- check for pausejob flag before relaunching:---------------------------------------------- 
if [ -f pausejob ]; then 
 echo -e "P:Paused">.job_status
 exit 
fi 

## -- if all ok, relaunch job:-----------------------------------------------------------------
echo -e "P:Submitted">.job_status
qsub $pbs_prod

## --------------------------------------------------------------------------------------------

