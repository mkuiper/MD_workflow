# Ligand conformation cluster analysis: 
# -this script loads in ligand chains (as defined in clustering_configuration.tcl) 
# and performs a clustering analysis.  Frames from a particular cluster 
# are merged and averaged to produce a pdb file representative of that 
# binding location.  This script takes into account some simulations having more
# more than one of the same ligand (with different chain names)

set out [open "summary.txt" a]
# -- re-read reduced data:--------------------------------------------------------- 
mol delete top
mol new no_water_no_hydrogen.psf type {psf} first 0 last -1 step 1 waitfor all
mol addfile no_water_no_hydrogen.dcd type {dcd} first 0 last -1 step 1 waitfor all

source clustering_configuration.tcl
puts " starting ligand cluster analysis: - this may take some time! "

# -- merge multiple (same) ligands into one trajectory file:----------------------- 
set chain_sel [atomselect top "chain $i" ]
$chain_sel writepsf temp_data_dir/tmp_ligand.psf

foreach i $ligand_chain_list {

set chain_sel [atomselect top "chain $i" ]
puts " merged ligand chain $i "
animate write dcd temp_data_dir/tmp_ligand$i.dcd beg 0 end -1 waitfor all sel $chain_sel

# grab last chain name in series: 
}
puts " finished merging ligand trajectories "

# -- read in one ligand only:--------------------------------------------------------- 
mol delete top
mol new temp_data_dir/tmp_ligand.psf type {psf} first 0 last -1 step 1 waitfor all

# -- load combined trajectories:
foreach i $ligand_chain_list {
mol addfile temp_data_dir/tmp_ligand$i.dcd type {dcd} first 0 last -1 step 1 waitfor all
}

set sel [atomselect top all ]
set cluster_list [measure cluster $sel num $lc distfunc rmsd cutoff $ligco ]

# --pull out separate frames of clusters groups:---------------------------------- 
for { set j 0 } { $j < $lc } { incr j } {  
 set ff [open "ligand_cluster_data/ligand_cluster_member_list.$j.txt" w ] 
 set  cc [ lindex $cluster_list $j ]
 puts $ff $cc 
 close $ff
 foreach z $cc {
 animate write dcd temp_data_dir/temp_ligand_cluster.$j.$z.dcd beg $z end $z waitfor all sel $sel
 }
}

# -- use catdcd to merge cluster groups:------------------------------------------ 
exec Scripts/merge_ligand_clusters_script $lc 
source Scripts/trajectory_smooth.tcl 

puts " Merging ligand clusters "
sleep 2;

puts $out " ligand cluster cutoff:  $ligco"                   
puts      " ligand cluster cutoff:  $ligco"

for { set i 0 } { $i < $lc } { incr i } {  

# -- delete current frames; read in cluster frames:-------------------------------
 
animate delete  beg 0 end -1 skip 0 top
set dcdfile ligand_cluster_$i.dcd
mol addfile $dcdfile type dcd first 0 last -1 step 1 waitfor all 
set frame_no [molinfo top get numframes]

puts $out "ligand cluster $i \t\t $frame_no members" 
puts " Done with ligand cluster $i \t\t $frame_no members" 

# -- write out averaged ligand cluster:-------------------------------------------
set avgpos [avg_position $sel ligand_cluster_data/ligand_cluster.$i.pdb beg 0 end last writesel selonly]
set dev [dev_pos $sel $avgpos]
set mean_dev  [mean $dev ]

# -- cleanup:
exec mv ligand_cluster_$i.dcd ligand_cluster_data/
puts $out " "                   
}
close $out

