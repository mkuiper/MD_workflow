#
# Cluster analysis: 
# protein conformation rmsd clustering: 
# number of clusters: 
set cn 10

set sel [atomselect top {chain B}]
set sel_all [atomselect top all]
puts " starting protein cluster analysis: - this may take some time!"
set cluster_list [measure cluster $sel num $cn distfunc rmsd  ]

# pull out separate frames of clusters to generate ligand density: 
 
for { set j 0 } { $j < $cn } { incr j } {  
set  c [ lindex $cluster_list $j ]
foreach i $c {
animate write dcd temp_cluster.$j.$i.dcd beg $i end $i waitfor all sel $sel_all
}
}

# use catdcd to merge files: 
exec Scripts/merge_clusters_script 10 


