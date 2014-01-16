#------------------------------------------------------------------------------
# Namd Analysis job directory notes.  v0.1               May 2013  MKuiper VLSCI
#------------------------------------------------------------------------------

# Disclaimer! - I have made this workflow to help manage my own projects, 
- you are free to use it, but it may not be entirely suitable for what you are 
trying to achieve.  Please email feedback, bugs or suggestions to:
mkuiper@unimelb.edu.au

#------------------------------------------------------------------------------

The /Analysis directory is desigend to be used at the completion of a run as a
place to consolidate data and process the trajectory data. 

There are a number of sub_directories and scripts here to help you do this: 
#------------------------------------------------------------------------------

 /Data
 /temp_data_dir
 /Scripts
 /protein_cluster_data
 /ligand_cluster_data

- a1_extract_all_my_data.sh       - script to extract paths to dcd data in 
                                    /MainJob_dir

- a2_create_no_H_no_H2O_dcd.sh    - script to create a greatly reduced data 
                                    file containing not water or hydrogen.  

- a3_protein_backbone_cluster_analysis.sh


- a4_ligand_cluster_analysis.sh

- clustering_configuration.tcl   - configuration script for analysis. 


#------------------------------------------------------------------------------

The scripts above are designed to be run in order,  a1_, a2_, ..etc but certain 
analysis can be omitted if necessary. 







