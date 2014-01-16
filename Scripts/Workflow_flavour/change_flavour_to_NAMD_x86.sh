#!/bin/bash
#                                                             mkuiper May 2013
# Simple script to change the flavour of the work directory from NAMD for the 
# bluegene/Q to NAMD for the x86 cluster.


# read current state: 
md_flavour=$( less .current_md_workflow_flavour | awk '{print $1 }' )  
scheduler_flavour=$( less .current_md_workflow_flavour | awk '{print $2 }' )  
machine_flavour=$( less .current_md_workflow_flavour | awk '{print $3 }' )  
                        
echo -e "Current flavours: " 
echo  $md_flavour $scheduler_flavour $machine_flavour
 
echo -e "\nNew flavours: "
echo -e "NAMD PBS x86"






