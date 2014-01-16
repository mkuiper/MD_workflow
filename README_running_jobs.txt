
# /Simulation directory notes:             May 2013 mk

#  Before you can launch jobs, you must first setup your files and create 
your job directories, which you can do from: 

/Setup_and_Config 

From there you can also precheck your input files as well as run a few 
benchmarks to choose optimal numbers of cores to use for the simulation. 

Once you have these set up, you can start all your jobs at once with: 

./start_all_jobs.sh 


In order to stop your jobs use either: 

./stop_all_jobs_gently.sh
 
or 

./stop_all_jobs_immediately.sh 


The advantage with the first option is that it does so more cleanly as well
as being able to be restarted with:

./restart_all_production_jobs.sh 

While the jobs are running, one can monitor their progress by using: 

./monitor_all_jobs.sh

This program will tag all crashed jobs with a 'pausejob' file for restarting. 


######################  
#  Crash recovery:   #
######################

In the event of a system crash, such as a power outage or hardware failure one can 
perform a recovery which restores your files to the last known good point. To do 
this, first make sure all your jobs are stopped, (try ./stop_all_jobs_immediately)
and then run the script:

./recover_and_cleanup_crashed_jobs.sh

This should take you into each directory to manually inspect the outputfiles where 
you can declare the last good outputfile. The script will then scrub subsequent "bad" 
output and restore data from the last "good" simulation. 
 
For example, when one runs the script after a crash in the OutputFiles/ you might see 

-rw-r--r-- 1 mike mike 21931876 Sep  4 17:54 2012-09-04-05.44.calmodulin_run2_.10.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  5 05:54 2012-09-04-17.54.calmodulin_run2_.9.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  5 18:05 2012-09-05-05.54.calmodulin_run2_.8.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  6 17:02 2012-09-06-17.02.calmodulin_run2_.7.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  6 17:53 2012-09-06-17.52.calmodulin_run2_.6.dcd
-rw-r--r-- 1 mike mike  3789024 Sep  7 06:08 2012-09-06-17.57.calmodulin_run2_.5.dcd
-rw-r--r-- 1 mike mike 15373446 Sep  7 06:08 2012-09-07-06.08.calmodulin_run2_.4.dcd

Looking at the size of the files we notice that job 2012-09-06-17.57.calmodulin_run2_.5.dcd
has a file size of 3789024 where preceeding files sizes are the same at  21931876
As we expect the files sizes to be almost identical in size, we can assume that something when
wrong at that step.  Therfore the last "good" file is 2012-09-06-17.52.calmodulin_run2_.6.dcd
which we enter when prompted. (cut and paste works well here!) 

Be careful to pick the last good file,  - data after that point will be removed and the last 
good restart files retrieved ready to restart the simulations from that point onwards. 

Note:  Actually most bad files are moved to /Errors with a suffix ".bad"
You can remove them there with a "rm *.bad" command.  Use with caution!

Once you have reset your directories, you can then simply restart the jobs using: 

 ./restart_all_production_jobs.sh
   

*** If your jobs are a total mess and you wish to remove all data and 
start again you may do so from the directory /Setup_and_Config/Scripts using

 ./erase_all_data_cleanup_script.sh 

CAREFUL, this will do what it says! 

     

 
