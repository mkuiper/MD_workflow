proc rmsd_residue_over_time {{mol top} res} {
    # use frame 0 for the reference
    set reference [atomselect $mol "protein" frame 0]
    # the frame being compared
    set compare [atomselect $mol "protein"]
    #make a selection with all atoms
    set all [atomselect top all]
    #get the number of frames
    set num_steps [molinfo $mol get numframes]
    #open file for writing
    set fil [open residue_rmsd.dat w]
    #write title to file
    #puts $fil "residue \t rmsd"
    

    foreach r $res {
	set rmsd($r) 0
    }
    
    #loop over all frames in the trajectory
    for {set frame 0} {$frame < $num_steps} {incr frame} {
	puts "Calculating rmsd for frame $frame ..."
	# get the correct frame
	$compare frame $frame
	# compute the transformation
	set trans_mat [measure fit $compare $reference]
	# do the alignment
	$all move $trans_mat
	# compute the RMSD
	
	#loop through all residues
	foreach r $res {
	    set ref [atomselect $mol "chain A and resid $r and noh" frame 0]
	    set comp [atomselect $mol "chain A and resid $r and noh" frame $frame]
	    set rmsd($r) [expr $rmsd($r) + [measure rmsd $comp $ref]]
	    #puts [measure rmsd $comp $ref]
	}
    }
    set ave 0
	foreach r $res {
	    set rmsd($r) [expr $rmsd($r)/$num_steps]
	    # print the RMSD
	    puts "RMSD of residue $r is $rmsd($r)"
	    puts $fil " $r \t $rmsd($r)"
	    [atomselect $mol "resid $r"] set beta $rmsd($r)
	    set ave [expr $ave + $rmsd($r)]
	    
	}
    set ave [expr $ave/[llength $res]]
    puts " Average rmsd per residue:   $ave"
    close $fil
}


