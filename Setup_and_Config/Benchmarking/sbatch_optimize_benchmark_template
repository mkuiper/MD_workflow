#!/bin/bash
## sbatch template for benchmarking                   June   2012     MKuiper

#---------------------------------------------------------------------------------
#-- Sbatch parameters:------------------------------------------------------------
#SBATCH --nodes=8
#SBATCH --time=4:0:0
#SBATCH --account=Change_me

#number of tasks per node: 
ntpn=32
## processors per node: 
## ppn=8

jobname=optimize_bench

#load module file:
module load namd-xl-pami/2.9

# check for master_config_file and source variables for both optimization and production scripts: 

if [ -f ../master_config_file ];then
. ../master_config_file

else 
 echo -e "\n Can't find "master_config_file"!\n"
 exit
fi


#---------------------------------------------------------------------------------
#-      You shouldn't have to change anything below this line!              ---
#---------------------------------------------------------------------------------

### - date stamps:-------------------------------------------------------------------
date=$(date +%F);
date2=$(date +%F-%H.%M);

### - write to the job_log:---------------------------------------------------------- 
scontrol show job $SLURM_JOBID >>JobLog/$date2$jobname_prod.qstat.txt;
echo $SLURM_JOBID >>JobLog/current_job_id.txt

### - run production job segment:----------------------------------------------------
basename="$date2.$jobname" 

# for avoca
srun  --ntasks-per-node=$ntpn  namd2 bench_opt.conf >OutputText/$basename.out 2>Errors/$basename.err;

###  - clean up files:---------------------------------------------------------------
# - mine timing / seed data: 
timing=$(../../Scripts/Tools/timing_data_miner OutputText/$basename.out);
echo $basename  $jobhours "hours runtime " $timing  >>TimingData/timing_data_log.txt;

rm FFTW*
rm *.restart* 
rm *.old 
rm *.colvars* 
rm *.BAK
rm *.dcd 
rm *.xst
mv slur* Errors/


