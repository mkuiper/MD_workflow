# Go through each frame of the trajectory
# Output a lot of information
# a - atomselection on protein
# b - atomselection on ligand
# r - optional distance cutoff (default is 2 Å)
proc trajscan {a b {r 2.0}} {
    set oldframe [molinfo top get frame]
    set protein_text [$a text]
    set ligand_text [$b text]
    for {set i 0} {$i < [molinfo top get numframes] } {incr i} {
	molinfo top set frame $i
	set contact [measure contacts $r $a $b]
	if {[llength [lindex $contact 0]] > 0} {
	    puts "============================================="
            set protein_contact [lindex $contact 0]
            set ligand_contact [lindex $contact 1]
            set protein_atoms [atomselect top "index $protein_contact"]
	    set ligand_atoms [atomselect top "index $ligand_contact"]
	    # how many ligands are in contact with the protein
	    set ligand_residues [lsort -unique [$ligand_atoms get resid]]
	    set nligand [llength $ligand_residues]
            puts "Frame:$i"
	    puts "$nligand ligand(s) in contact with protein"
	    for {set j 0} {$j < $nligand } {incr j} {
		# get the unique residues that we're coordinating with
		set ligand_resid [lindex $ligand_residues $j]
		set protein_lig_j [atomselect top "$protein_text and (within $r of $ligand_text and resid $ligand_resid)"]
		set protein_resid [lsort -unique [$protein_lig_j get resid]]
		set output_string "$ligand_resid: "
		for {set k 0} {$k < [llength $protein_resid]} {incr k} {
		    set sub_select [atomselect top "$protein_text and resid [lindex $protein_resid $k]"]
		    append output_string " [lindex $protein_resid $k] [lsort -unique [$sub_select get resname]]"
		}
		puts $output_string
	    }
	}
    }
    molinfo top set frame $oldframe
}

# As above, but just return minimal information on the number of
# frames where close fits are found.
proc trajscanstat {a b {r 2.0}} {
    set oldframe [molinfo top get frame]
    set count 0
    set nframe [molinfo top get numframes]
    for {set i 0} {$i < $nframe } {incr i} {
	molinfo top set frame $i
	set contact [measure contacts $r $a $b]
	if {[llength [lindex $contact 0]] > 0} {
	    incr count
	}
    }
    molinfo top set frame $oldframe
    puts "============================================="
    puts "$count hits"
    puts "[molinfo top get numframes] frames"
    set ratio [expr double($count) / double($nframe)]
    puts "ratio: $ratio"
    puts "============================================="
}

# As trajscanstat, but a list of protein atom selections is passed in.
# If all atomselections are found to be true, the frame is counted.
proc trajscanstatm {alist b {r 2.0}} {
    set oldframe [molinfo top get frame]
    set hits 0
    set nframe [molinfo top get numframes]
    set nselect [llength $alist]
    set hitlist [list]
    for {set i 0} {$i < $nframe } {incr i} {
	molinfo top set frame $i
	set count 0
	for {set sel 0} {$sel < $nselect} {incr sel} {
	    set a [lindex $alist $sel]
	    set contact [measure contacts $r $a $b]
	    if {[llength [lindex $contact 0]] > 0} {
		incr count
	    }
	}
	if {$count == $nselect} {
	    incr hits
	    lappend hitlist $i
	}
    }
    molinfo top set frame $oldframe
    puts "============================================="
    puts "$hits hits"
    puts "[molinfo top get numframes] frames"
    set ratio [expr double($hits) / double($nframe)]
    puts "ratio: $ratio"
    puts "============================================="
    return $hitlist
}

# Go through each frame of a trajectory and output the vector
# connecting the center of mass of two atom selections and the length
# of the vector.  If a file name is given, write this distance to a
# file.
proc mbondscan {a b {fname "noFile"}} {
    set oldframe [molinfo top get frame]
    set nframe [molinfo top get numframes]
    if {$fname == "noFile"} {
	set writeFile 0
    } else {
	set fh [open $fname "w"]
	set writeFile 1
    }
    for {set i 0} {$i < $nframe} {incr i} {
	molinfo top set frame $i
	set coma [lindex [measure inertia $a] 0]
	set comb [lindex [measure inertia $b] 0]
	set ab [vecsub $comb $coma]
        set rab [vecdist $comb $coma]
        if {$writeFile==1} {
	    puts $fh "$i $rab $ab"
	} else {
	    puts "$i $rab $ab"
	}
    }
    if {$writeFile==1} {
	close $fh
    }
    molinfo top set frame $oldframe
}

proc inertiascan {a b fnamedist fnameangle } {
    set oldframe [molinfo top get frame]
    set nframe [molinfo top get numframes]
    set fdist [open $fnamedist "w"]
    set fangle [open $fnameangle "w"]
    for {set i 0} {$i < $nframe} {incr i} {
	molinfo top set frame $i
	set ina [measure inertia $a]
	set inb [measure inertia $b]
	set ab [vecsub [lindex $ina 0] [lindex $inb 0]]
	set orienta [lindex [lindex $ina 1] 1]
	set orientb [lindex [lindex $inb 1] 1]
	set rab [veclength $ab]
	set dotab [vecdot $orienta $orientb]
	puts $fdist "$rab"
	puts $fangle "[expr {acos([expr {abs($dotab)}])}]"
    }
    close $fdist
    close $fangle
    molinfo top set frame $oldframe
}

# Go through each frame of a trajectory and output the angle between
# the center-of-mass of the three atomselections: a,b & c.  If a file
# name is given, write this angle to a file. The angle is given in
# both degrees and radians.
proc anglescan {a b c {fname "noFile"} } {
    set oldframe [molinfo top get frame]
    set nframe [molinfo top get numframes]
    if {$fname == "noFile"} {
	set writeFile 0
    } else {
	set fh [open $fname "w"]
	set writeFile 1
    }
    for {set i 0} {$i < $nframe} {incr i} {
	molinfo top set frame $i
	set coma [lindex [measure inertia $a] 0]
	set comb [lindex [measure inertia $b] 0]
	set comc [lindex [measure inertia $c] 0]
	set ab [vecsub $comb $coma]
	set bc [vecsub $comc $comb]
	set dab [vecnorm $ab]
	set dbc [vecnorm $bc]
	set cos_abc [vecdot $dab $dbc]
	set abc [expr { acos($cos_abc) }]
	set aabc [expr { 180*$abc/3.14159265358979323846} ]
	if {$writeFile==1} {
	    puts $fh "$aabc $abc"
	} else {
	    puts "$aabc $abc"
	}
    }
    if {$writeFile==1} {
	close $fh
    } 
    molinfo top set frame $oldframe
}

# Go through each frame of a trajectory and calculate the radius of
# gyration of the input atomselection. If a filename is given, write
# the radius to the file.
proc rgyrscan { a {fname "noFile"} } {
    set oldframe [molinfo top get frame]
    set nframe [molinfo top get numframes]
    if {$fname == "noFile"} {
	set writeFile 0
    } else {
	set fh [open $fname "w"]
	set writeFile 1
    }
    for {set i 0} {$i < $nframe} {incr i} {
	molinfo top set frame $i
	set rg [ measure rgyr $a]
	if {$writeFile==1} {
	    puts $fh "$i $rg"
	} else {
	    puts "$i $rg"
	}
    }
    if {$writeFile==1} {
	close $fh
    } 
    molinfo top set frame $oldframe
}
    

# Go through each frame of a trajectory and output the dihedral angle between
# the center-of-mass of the four atomselections: a,b, c &d.  If a file
# name is given, write this angle to a file. The angle is given in
# both degrees and radians.
proc dihedralscan { a b c d {fname "noFile"} } {
    set oldframe [molinfo top get frame]
    set nframe [molinfo top get numframes]
    if {$fname == "noFile"} {
	set writeFile 0
    } else {
	set fh [open $fname "w"]
	set writeFile 1
    }
    for {set i 0} {$i < $nframe} {incr i} {
	molinfo top set frame $i
	set coma [lindex [measure inertia $a] 0]
	set comb [lindex [measure inertia $b] 0]
	set comc [lindex [measure inertia $c] 0]
	set comd [lindex [measure inertia $d] 0]
	set ab [vecsub $comb $coma]
	set bc [vecsub $comc $comb]
	set cd [vecsub $comd $comc]
	set dab [vecnorm $ab]
	set dbc [vecnorm $bc]
	set dcd [vecnorm $cd]
	set cross_abbc [veccross $dab $dbc]
	set cross_bccd [veccross $dbc $dcd]
	set cos_abcd [vecdot $cross_abbc $cross_bccd]
	set abcd [expr { acos($cos_abcd) }]
	set aabcd [expr { 180*$abcd/3.14159265358979323846} ]
	if {$writeFile==1} {
	    puts $fh "$i $aabcd $abcd"
	} else {
	    puts "$i $aabcd $abcd"
	}
    }
    if {$writeFile==1} {
	close $fh
    }
    molinfo top set frame $oldframe	
}

# Write the indexes for the selection, sel, to a file fname.text and
# also write a corresponding psf file fname.psf
proc reduced { sel fname} {
    set f [open $fname.text "w"]
    puts -nonewline $f [$sel get index]
    close $f
    $sel writepsf $fname.psf
}

# get the total charge of an atomselection
proc get_charge {sel} {
    eval "vecadd [$sel get charge]"
}

## This takes a selection and fits that selection for every frame in the
## molecule (all atoms are moved, but the fit is based on the selection).
## 
## For example:  fitframes top "protein"
## 
## -Jim
proc fitframes { molid seltext } {
    set ref [atomselect $molid $seltext frame 0]
    set sel [atomselect $molid $seltext]
    set all [atomselect $molid all]
    set n [molinfo $molid get numframes]
    
    for { set i 1 } { $i < $n } { incr i } {
	$sel frame $i
	$all frame $i
	$all move [measure fit $sel $ref]
    }
    $ref delete
    $sel delete
    $all delete
    return
}

proc fitagainst { molid0 molid1 seltext } {
    set ref [atomselect $molid0 $seltext frame 0]
    set sel [atomselect $molid1 $seltext]
    set all [atomselect $molid1 all]
    set n [molinfo $molid1 get numframes]

    for { set i 0 } { $i < $n } { incr i } {
	$sel frame $i
	$all frame $i
        $all move [measure fit $sel $ref]
    }
    return
}

# for the given molid mark the beta column for the selection text to 1
proc mark_beta { molid seltext } {
    set all [atomselect $molid all]
    $all set beta 0
    set sel [atomselect $molid $seltext]
    $sel set beta 1
}

# write the sequence of the selection to fname, one line per residue
proc write_seq { molid seltext fname } {
    set sel [atomselect $molid "$seltext and name CA"]
    set nres [$sel num]
    set f [open $fname.text "w"]
    set data [$sel get {resid resname chain}]
    for {set i 1 } { $i < $nres } {incr i} {
	set this_data [lindex $data $i]
	set this_resid [lindex $this_data 0]
	set this_resname [lindex $this_data 1]
	set this_chain [lindex $this_data 2]
	puts $f "$this_resid $this_resname $this_chain"
    }
    close $f
}

# per residue rmsf to file
proc rmsfscan { sel fname } {
    set rmsf [measure rmsf $sel]
    set n [llength $rmsf]
    set f [open $fname.dat "w"]
    for {set i 0} {$i < $n} {incr i} {
	puts $f "$i [lindex $rmsf $i]"
    }
    close $f
}

proc switch_on_tube_scaling { {field beta}} {
    set env(VMDMODULATERIBBON) $field
}

# splits molecule into multiple fragments indexed by chain and fragment id
proc split_chain_fragments { mol } {
    set all [atomselect $mol all]
    set fragids [lsort -unique -integer [$all get fragment]]
    set nfrag [llength $fragids]
    for {set i 0} {$i < $nfrag} {incr i} {
	set frag [lindex $fragids $i]
	set sel [atomselect top "fragment $frag"]
	set chain [lsort -unique [$sel get chain]]
	$sel writepdb chain$chain\_fragment$frag.pdb
	$sel delete
    }
    $all delete
}

# reads a two column: <resid> <data>
# file and applies <data> to molid
proc apply_beta_from_file {fname molid} {
    set fp [open $fname r]
    set lines [read $fp]
    close $fp
    set data [split $lines "\n"]
    foreach line $data {
	set line_length [llength $line]
	if {$line_length==2} {
	    set resid [lindex $line 0]
	    set rmsf [lindex $line 1]
	    set sel [atomselect $molid "protein and resid $resid"]
	    $sel set beta $rmsf
	    $sel delete
	}
    }
}

# work on the assumption that there is only one representation for
# molid
proc twitch_reps {molid} {
    mol representation points 10
    mol selection "name C"
    mol modrep 0 $molid
    mol representation points 36
    mol selection "name O"
    mol addrep $molid
    mol smoothrep $molid 1 20
}