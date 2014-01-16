#                                                                mk  Jan 2013 
# This tcl script is used to generate a reduced selection (not water) by using 
# the analysis.tcl script for easier analysis on machines with less memory. 
#------------------------------------------------------------------------------
# open output file:
set out [open "summary.txt" a]

# read in raw data: 
puts " reading in entire data set:"
source basic_vmd_setup.vmd
source combined_dcd_loader_script.vmd 

# load useful analysis script:  
source ../Scripts/Tcl_Scripts/analysis.tcl
source clustering_configuration.tcl 

set frame_no [molinfo top get numframes]
set num_all [$sel_all num ] 
set cha_all [get_charge $sel_all ] 

puts $out " Total charge:         $cha_all  " 
puts $out " Total frame numbers:  $frame_no \n " 
puts $out " Total atoms:          $num_all  " 

#------------------------------------------------------------------------------
puts " creating reduced selection of data: no water no hydrogen"

set sel [atomselect top {not water and not hydrogen}]
reduced $sel no_water_no_hydrogen
set num_sel [$sel num]
puts $out " Total reduced atoms:  $num_sel \n  " 

# write out reduced data: 
animate write dcd no_water_no_hydrogen.dcd waitfor all sel $sel

puts " reading in reduced data"

# delete original; read in reduced data set: 
mol delete top
mol new no_water_no_hydrogen.psf type {psf} first 0 last -1 step 1 waitfor all
mol addfile no_water_no_hydrogen.dcd type {dcd} first 0 last -1 step 1 waitfor all
set sel_all [atomselect top {not water and not hydrogen}]

#------------------------------------------------------------------------------
puts " aligning protein backbone in reduced data"

# fit reduced data to first frame and protein backbone: 
fitframes top $sel_protein

# write out aligned reduced data: 
animate write dcd no_water_no_hydrogen.dcd waitfor all sel $sel_all

#-- Some quick and easy things to caclulate:-----------------------------------
if {$calc_rog == 1} {
 puts " calculating radius of gyration of protein backbone: " 
 rgyrscan $sel_all  protein_radius_gyration.txt 
}

if {$calc_rmsf == 1} {
 puts " calculating rmsf of protein backbone "
 set sel_ca [atomselect top { protein and name CA } ]  
 rmsfscan $sel_ca rmsf_protein_backbone.txt
}

# clean up
close $out

