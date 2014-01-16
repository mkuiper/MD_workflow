# Cluster analysis: 
# protein conformation rmsd clustering: 

# read in configuration file: 
source clustering_configuration.tcl
set out [open "summary.txt" a]

# -- protein backbone clustering------------------------------------------------------

animate delete  beg 0 end -1 skip 0 top
mol addfile no_water_no_hydrogen.dcd type {dcd} first 0 last -1 step 1 waitfor all

puts " starting protein cluster analysis: - this may take some time!"
set sel [atomselect top "$sel_protein" ]
set cluster_list [measure cluster $sel num $pc distfunc rmsd cutoff $proco ]

# pull out separate frames of clusters groups----------------------------------------- 

for { set j 0 } { $j < $pc } { incr j } {  
 set ff [open "protein_cluster_data/protein_cluster_member_list.$j.txt" w ] 
 set  c [ lindex $cluster_list $j ]
 puts $ff $c 
 close $ff
 foreach i $c {
 animate write dcd temp_data_dir/temp_protein_cluster.$j.$i.dcd beg $i end $i waitfor all sel $sel_all
 }
}

# -- use catdcd to merge protein cluster groups:-------------------------------------- 
exec Scripts/merge_protein_clusters_script $pc 
puts " merging protein backbone " 
sleep 5

source Scripts/trajectory_smooth.tcl 
source clustering_configuration.tcl

puts $out " protein cluster cutoff:  $proco" 
puts      " protein cluster cutoff:  $proco" 

#-------------------------------------------------------------------------------------
for { set k 0 } { $k < $pc } { incr k } {  
# delete current frames: 
animate delete  beg 0 end -1 skip 0 top

# read in cluster data: 
set dcdfile protein_cluster_$k.dcd
mol addfile protein_cluster_data/$dcdfile type dcd first 0 last -1 step 1 waitfor all 

set frame_no [molinfo top get numframes]
puts $out "protein cluster $k \t\t $frame_no members" 

# write out averaged ligand cluster:
set avgpos [avg_position $sel protein_cluster_data/protein_backbone_cluster.$k.pdb beg 0 end last writesel selonly]
set dev [dev_pos $sel $avgpos]
set mean_dev  [mean $dev ]
puts " Done with Protein_backbone_cluster.$k     $frame_no members"
    
}

puts $out "--------------------" 
close $out

