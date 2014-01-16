#-----------------------------------------------------------------------------#
# Namd project job directory notes.  (v0.4)   	   Jan 2014  MKuiper VLSCI    #
#-----------------------------------------------------------------------------#

# Disclaimer! - I have made this workflow originally to help manage my own 
 projects, - you are free to use it, but it may not be entirely suitable for 
 what you are trying to achieve. Please email feedback, bugs or suggestions to:
 mkuiper@unimelb.edu.au

#
# Outline:
#-----------------------------------------------------------------------------#

 This project directory structure is designed to help streamline the management 
 of simulation setup, running jobs, analysis and the writing of manuscripts.
 Though this directory structure is optimized for NAMD operating on a large 
 BlueGene/Q cluster, it could quite easily adapted for running other programs 
 such as Amber and Gromacs. 


# 
# The philosophy:
#-----------------------------------------------------------------------------# 

 This folder came about to help manage and organize the running of a few to 
 thousands of simultaneous molecular dynamics simulations to take advantage of 
 the large capacity of the BlueGene/Q cluster.  

 The directory structure is designed to be self-contained; that is having all 
 the files necessary to run a simulation. The /Project directory is meant to be 
 the area to work on manuscripts and illustrations while the /BUILD_DIR  is 
 where users can build up their simulations.  The /Setup_and Config directory 
 is where users setup and optimize and benchmark their systems before launching
 production jobs.   

 This directory structure is intended for a standard namd job comprising of an 
 equilibration run followed by production runs.  Output files are date-stamped 
 and moved to various folders designed to keep data ordered so as to be able to 
 replicate or validate any point of the simulation.  

 Under the /MainJob_dir we run our independant simulations. These variables 
 are set under the "master_config_file" in the /Setup_and_Config directory. 
 The variable "sims" sets up how many simulation directories we set up. 
 The variable "runs" will set how many times we run the production script. 
 For example, if in our sim_production.conf we set a simulation segment 
 to run for 2 nanoseconds, and we set our runs to be 20, then the production
 script will be run 20 times, producing 2x20 ns = 40 ns worth of simulation. 
 If we had set up say 4 simulation directories we would expect to generate 
 4 times this of data, ie) 4x 2x 20 = 160ns.  As the production simulations 
 run, a hidden counter in the simulation directory .countdown.txt keeps track 
 of the progress. The simulation stops once this counter reaches 0. 

 If we like how our simulations ran and want to extend the simulation, 
 - perhaps run another 20 segments, we can do so by running: 
 ./initialize_new_round.  This will reset the simulation and increment 
 the round counter by 1. The next round will be a continuation of the 
 previous simulation using the prior restart files.  


 The directory structure also helps addresses the problem of group quota 
 on the queuing system by running many smaller jobs rather than fewer longer 
 jobs to get a desired simulation length. This approach can also help better 
 utilise the machine resources as well as providing better protection against 
 data corruption in case of hardware or simulation failures over the course 
 of a long run. All trajectory data can be trivially consolidated into a single 
 file on completion of the runs from the /Analysis folder.  Typically we try 
 to keep job segments (or runs) finishing in 12 to 24 hours.  

 




 
 A basic workflow is described after the directory structure. 

#
# Directory Structure Map Overview:
#-----------------------------------------------------------------------------# 

|__Top_directory  
  |                -- The place for running simulations.	                 
  |                   Launch and control jobs from here. 
  |
  |__Analysis          - where analysis scripts are run   
  |   |
  |   |__Data          - where all the processed data ends up
  |
  |__BUILD_DIR         - where models are built. 
  |
  |__Examples          - random example files 
  |
  |__InputFiles        - where all the input files are kept
  |    |
  |    |__Parameters   - where the parameter files are
  | 
  |__MainJob_dir       - where all the job directories are run 
  |
  |__Setup_and_Config  - an important directory where setup scripts are kept  
  |    |
  |    |__Benchmarking - special directory for benchmarking and optimizing jobs  
  |    |__JobTemplate  - directory template for individual jobs 
  |
  |__Scripts           -  all useful scripts kept in here
  |    |__             .. 
  |  
  |__Project           --- For publication purposes
       |   
       |___Manuscripts   - a space for writing and storing images
       |___MovieBox	 - a space for rendering movies                       
       |___ProjectPlan   - A space to document and plan the project. 
          
 
#
# The general work flow:   
#-----------------------------------------------------------------------------# 

 Before starting any new project it is always a good idea to make a plan with 
 regards to the work and expected outcomes. For this we a simple text document 
 called "Project_plan" in the top directory. It is a good place for documenting 
 the your original intentions and noting your project design.  This can be 
 especially important when looking back on an older project and remembering the 
 original rationale! Do make sure to spend time planning your work.


 The basic workflow of this directory structure is described here. 
 (There are more specific README files in each of the directories.) 

1. Build input models.    /BUILD_DIR

 - The place to do this is under /BUILD_DIR/
 - most topology and parameter files can be found under /Parameters 
 - Once complete, place the relevant inputfiles under /InputFiles 
   and make sure you have the right parameter files under /Parameters

2. Prepare your input files.      /Setup_and_Config

- Under /Setup_and_config you can decide how many simulations to set up
  by editing the  'master_config_file'  
  You can also run:  
 
   ./prerun_checkjob.sh  

 to make sure you have things in place and calculate how much diskspace 
 you might use.  (note! This script only properly calculates the diskspace 
 used properly when run from MERRI as the catdcd is for x86 architecture) 
 A number of sbatch templates and example namd config files are stored 
 here for you to modify for your specific job.  ie) 

 sbatch_start        -  for setting up the equilibration step     
 sim_opt.conf        -  the configuration file for the optimization step

 sbatch_production   -  for the production runs    
 sim_production.conf -  the configuration file for the production runs


3. Benchmark your sims.   /Setup_and_Config/Benchmarking  

- In order to check your jobs and optimize the numbers of cores used per 
  simulation, make sure to go into /Setup_and_Config/Benchmarking  
  Re-edit your sbatch files in /Setup_and_Config to use the appropriate 
  numbers of CPUs. 

- This is a really good time to not only benchmark your jobs to find an ideal 
  node configuration but also a good chance to look at your simulation to check 
  that it runs properly and that your model is sound.   Nothing worse than 
  running a lot of simulations to find that there is an error in the model!   


4. Create and prepare job directories.

-From /Setup_and_Config use:

  ./create_job_directories.sh  

to create your job directories in /MainJob_dir use:

  ./populate_config_files.sh   

 to fill these directories with input files. ( You can also use this 
 script to update the input files in the job directories while a production 
 run is running. ) 
    

5. Run/manage  your jobs.          /Top_directory

- From /Simulation use the script: 
   ./start_my_jobs.sh         to start your simulations. 
    
 This will descend into each directory in /MainJob_dir and launch  
 'sbatch sbatch_start'     

 This in turn will run the equilibration simulation before starting 
 'sbatch sbatch_production' 
 This will generate production data stored in each job directory. 
    
 If you need to stop your jobs you can do so with:

  ./stop_all_jobs_gently.sh 

  or 

  ./stop_all_jobs_immediately.sh 

 The advantage with the first is that you can restart your jobs later with: 

  ./restart_all_production_jobs.sh

 While the jobs are running you can check on their progress with: 

  ./monitor_all_jobs.sh

Notes on jobs as they are running: 
In each job directory there are a number of hidden files that are used to keep track
of the system status. Users don't need to worry about them but they are: 

.countdown.txt       - file to countdown the runs of a particular simulation 
.current_job_id.txt  - current job id number
.jobdir_id           - current simulation directory
.job_status          - current job status summary
.old_slurm_file      - old slurm file for housekeeping purposes

pausejob             - flag to stop jobs in event of something wrong. 




#  
#  Crash recovery: 
#-----------------------------------------------------------------------------# 

 In the event of a system crash, such as a power outage or hardware failure one
 can perform a recovery which restores your files to the last known good point.
 To do this, first make sure all your jobs are stopped, 
 (try ./stop_all_jobs_immediately) and then run the script:

    ./recover_and_cleanup_all_crashed_jobs.sh

 This should take you into each directory to manually inspect the outputfiles 
 where you can declare the last good outputfile. The script will then scrub 
 subsequent "bad" output and restore data from the last "good" simulation. 
 
 For example, when one runs the script after a crash in the OutputFiles/ you 
 might see: 

-rw-r--r-- 1 mike mike 21931876 Sep  4 17:54 2012-09-04-05.44.calmodulin_run2_.10.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  5 05:54 2012-09-04-17.54.calmodulin_run2_.9.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  5 18:05 2012-09-05-05.54.calmodulin_run2_.8.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  6 17:02 2012-09-06-17.02.calmodulin_run2_.7.dcd
-rw-r--r-- 1 mike mike 21931876 Sep  6 17:53 2012-09-06-17.52.calmodulin_run2_.6.dcd
-rw-r--r-- 1 mike mike  3789024 Sep  7 06:08 2012-09-06-17.57.calmodulin_run2_.5.dcd
-rw-r--r-- 1 mike mike 15373446 Sep  7 06:08 2012-09-07-06.08.calmodulin_run2_.4.dcd

 Looking at the size of the files we notice that job:
 2012-09-06-17.57.calmodulin_run2_.5.dcd

 has a file size of 3789024 where preceeding files sizes are the same at
 21931876 As we expect the files sizes to be almost identical in size, we can 
 assume that something when wrong at that step. Therfore the last "good" file is 

 2012-09-06-17.52.calmodulin_run2_.6.dcd

 which we enter when prompted. (cut and paste works well here.) 

 Be careful to pick the last good file,  - data after that point will be removed
 and the last good restart files retrieved ready to restart the simulations from
 that point onwards. 

Note:  Actually most bad files are moved to /Errors with a suffix ".bad"
You can remove them there with a "rm *.bad" command.  Use with caution!

Once you have setset your directories, you can then simply restart the jobs using: 

 ./custom_start_all_production_jobs.sh
   
*** If your jobs are a total mess and you wish to remove all data and 
    start again you may do so from the directory /Setup_and_Config/ using:

  ./erase_all_data_cleanup_script.sh 

 CAREFUL, this will do what it says! 
     


6. Analyze your results.     /Analysis

- Once all your jobs are done, you can go into this directory and pool all the 
 simulation data from all the directories and run some basic analysis as well 
 as ligand and protein backbone clustering. 
 This can also help make the files more manageable by creating a subset of data 
 where all the water and hydrogens are removed. 
 Be sure to look at the README there! 


7.  Writeup, make movies.    /Project/

- the /Project directory is all about writing up the associated manuscript
  and making any illustrations or movies from the simualtion files. 

#-----------------------------------------------------------------------------# 

