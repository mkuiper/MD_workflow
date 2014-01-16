#!/bin/bash

##>-----------------------------------------------------------------------------------------
# common functions for prerun checkjob. 
extract_input_files(){

opt_dcd=$( less    $optimize_script   |grep dcdfreq | awk '{print $2;}'  )
prod_dcd=$( less   $production_script |grep dcdfreq |awk '{print $2;}' )

opt_input=$( less  $optimize_script   |grep 'coordinates\|structure'    | awk '{print $2;}' )
prod_input=$( less $production_script |grep 'coordinates\|structure' | awk '{print $2;}' )

opt_param=$( less  $optimize_script   |grep parameters | grep -v "#par" | awk '{print $2;}' )
prod_param=$( less $production_script |grep parameters | grep -v "#par" | awk '{print $2;}' )

# --check for existance of sbatch and configuration files: -----------------------------
# some error messages:
sb_st="not-found!---check-your-files!"
sb_pr="not-found!---check-your-files!"
op_scr="not-found!---check-your-files!"
pr_scr="not-found!---check-your-files!"

if [ -f  $sbatch_start ]; then
sb_st=" "
fi
if [ -f  $sbatch_prod ]; then
sb_pr=" "
fi
if [ -f  $optimize_script ]; then
op_scr=" "
fi
if [ -f $production_script ]; then
pr_scr=" "
fi

}

##>----------------------------------------------------------------------------------------
check_diskspace() {
warning=" "
diskspace=$( mydisk | grep $account | awk '{print $5}' | sed s/\%// )
gb_left=$( mydisk | grep $account | awk '{print $4}' | sed s/G//  )
my_disk=$( mydisk | grep $account )

intsize=$( echo $run_size | awk '{print int($1)}' )

if [ "$account" == "Change_me" ]; then
warning=" make sure to specify an account in master_config_file !"
fi

if [ "$diskspace" -gt "90" ]; then
warning=" Warning diskspace for this account is low! Check disk quotas  (mydisk)  "
fi

if  [ "$intsize" -gt "$gb_left" ]; then
warning=" You don't appear to have enough disk quota left! Check disk quotas (mydisk)  "
fi
}

##>----------------------------------------------------------------------------------------
extract_job_details(){
opt_dcd=$( less $optimize_script |grep dcdfreq | awk '{print $2;}'  )
prod_dcd=$( less $production_script |grep dcdfreq |awk '{print $2;}' )
opt_steps=$( less $optimize_script |grep dcdfreq | awk '{print $2;}'  )
prod_steps=$( less $production_script |grep NumberSteps | head -n 1 |awk '{print $3;}' )
pdb_file=$( less $production_script |grep coordinates | awk '{print $2;}' )
psf_file=$( less $production_script |grep structure | awk '{print $2;}' )
prod_fs_step=$( less $production_script | grep timestep | tail -n 1 |awk '{print $2;}' )
}


##>----------------------------------------------------------------------------------------
estimate_job_size(){
 
cd Benchmarking
size_per_frame=$( less $psf_file | grep NATOM | awk '{print $1*12/(1024*1024)}')
cd ../

frames=$( echo "$runs $sims $prod_steps $prod_dcd" |awk '{print ($1 *$2* ($3/$4) ) }')
run_size=$( echo " $size_per_frame $frames " |awk '{print $1*$2/1024}')
sim_time=$( echo " $prod_fs_step $prod_steps $sims $runs" |awk '{print ($1*$2*$3*$4)/1000000}')
opt_run_size=$( echo " $size_per_frame $opt_steps $opt_dcd $sims " |awk '{print ($1 * ($2/$3) * $4)/ 1024}')

# make integer of run_size and sim_time
int_run_size=${run_size/\.*}
int_sim_time=${sim_time/\.*}

# --make human readable!---------------------------------------------------------- 
size="Gigabytes"
time_units="nanoseconds"

if [ "$int_run_size" -gt "1024" ]
then
size="Terabytes"
run_size=$( echo "$int_run_size" |awk '{ print $1/1024}')
fi

if [ "$int_sim_time" -gt "1000" ]
then
sim_time=$( echo "$int_sim_time" |awk '{ print $1/1000}')
time_units="microseconds"
fi
if [ "$int_sim_time" -gt "1000000" ]
then
sim_time=$( echo "$int_sim_time" |awk '{ print $1/1000000}')
time_units="milliseconds"
fi
if [ "$int_sim_time" -gt "1000000000" ]
then
sim_time=$( echo "$int_sim_time" |awk '{ print $1/1000000000}')
time_units="seconds"
fi

}

#>------------------------------------------------------
# check inputfiles:
check_inputfiles(){ 
for k in $1 $2 
do
 if [ -f "$k" ]
  then
# - highlight colour if example file is still referenced. 
 if [[ $k == *example* ]]
  then
 printf "$c3%24s $c2 found $c8 -ok! -example file? $c0\n" $k
  else
 printf "%24s $c2 found $c8 -ok! $c0\n" $k
 fi
else
 printf "%24s $c4 not found in /InputFiles $c9 check your input files! $c0\n" $k
fi
done

} 

#>-------------------------------------------------------
check_paramfiles(){
if [ -f "$1" ] 
then 
 printf "%24s $c2 found $c8 -ok! $c0\n" $k  
else 
 printf "%24s $c4 not found in /Parameters $c9 check your input files! $c0\n" $k   
fi


}



