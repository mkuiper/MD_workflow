# Clustering analysis configuration  : 
# To set custom selections for clustal analysis:  

#-- Protein conformation analysis:---------------------------------------------

set pc    10   ;# number of protein backbone clusters to generate: 
set proco 5    ;# protein backbone cutoff factor

set sel_protein "protein and not hydrogen"  ;# protein selection 

#-- Ligand conformation analysis:----------------------------------------------

set lc    20     ;# number of ligand clusters to generate: 
set ligco 2.0    ;# ligand cutoff factor

set ligand_chain_list " B "   ;# set ligand selection 
#set ligand_chain_list " B C D "    # <- use this format for many ligands in the one simulation. 

# - In some simulations multiple ligands are included to increase the chance of binding events. 
# the chain list defines the chain names of these ligands so that they can be stitched into a 
# single trajectory to make ligand density mapping easier. 
# - this will greatly depend on you ligand names!! 

#-- Water analysis:-----------------------------------------------------------

set lig_water_radius  10    ;# set water extraction radius: 
set lig_water_radius  10 

#-- Misc. Selections:----------------------------------------------------------
set sel_all [atomselect top all]    ;# set "all" selection

#-- Optional calculations: 0 no  1 yes ----------------------------------------------------------------------------
set calc_rog  1   ;# calculate radius of gyration 
set calc_rmsf 1   ;# calculate rmsf of residues





