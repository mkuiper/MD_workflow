#---------------------------------------------------------------#
# -- Notes for benchmarking!                       Nov 2012 MK 
#---------------------------------------------------------------#
# -- Benchmarking for NAMD. 

Before you launch a large number of jobs it is often a good idea to benchmark 
your simulation to get a better idea of how your particular molecular dynamics 
simulation performs and what tradeoffs you might be prepared to make in 
choosing the optimum number of cores. 

This directory is designed to use your existing configuration files under 
/Setup_and_Config  

To prepare the benchmarking, first run: 

./setup_my_benchmarks.sh

This creates input files for the benchmarking process based on your production 
and optimization inputfiles.  Next run: 

sbatch sbatch_optimize_benchmark

One this finishes, it will automatically run: ./run_my_benchmarks
for the more rigorous benchmarking. 

This will launch a series of short jobs on a number of nodes with a combination 
of 'tasks per node'  and 'processor per node' options. As the jobs finish, the 
results will be summarized in: 

summary_benchmarks.txt

Note:
Depending on the version of namd you are using (either pami or smp) you will need to uncomment 
one of two 'srun'lines in sbatch_template: 

## smp version:
## srun  --ntasks-per-node=$ntpn  namd2 +ppn $ppn benchmark.conf >OutputText/$basename.out 2>Errors/$basename.err;
## pami version:
srun  --ntasks-per-node=$ntpn  namd2 benchmark.conf >OutputText/$basename.out 2>Errors/$basename.err;





