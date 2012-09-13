#!/bin/sh  
# \
exec tclsh "$0" ${1+"$@"}

#--------------------------------------------------
#$Header: /nfs/local/eda/eda_disk03/Layout/Custom/Laker/Scripts/RCS/trans_place.tcl,v 1.1 2012/03/04 09:11:00 cad Exp $
#-------------------------------------------------- 

#--------------------------------------------------
# Global variables
#-------------------------------------------------- 
set state flag
set X 0
set Y 0

proc Help {} {
	puts " -csv       { csv file         } "
	puts " -inst      { A B C ... X      } "
	puts " -usr_space { user space value } "
	puts " -L         { Transistor L     } "
	puts " -W         { Transistor W     } "
	puts " -out       { Output file      } "

	exit
}


#--------------------------------------------------
# Main part
#-------------------------------------------------- 
if {$argc < 1 || $argv == "-h" || $argv == "-help" || $argv == "--help" } {
	Help
} else {
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -regexp -matchvar raw -- $arg {
					-csv       { set state csv       }
					-inst      { set state inst      }
					-usr_space { set state usr_space }
					-L         { set state L         }
					-W         { set state W         }
					-out       { set state out       }
				}
			}
			out {
				set out $arg
				set state flag
			}
			csv {
				set csv $arg
				set state flag
			}
			inst {
				#--------------------------------------------------
				# Append inst index and accociated file
				#-------------------------------------------------- 
				lappend inst $arg  
				set state flag
			}
			usr_space {
				set usr_space $arg
				set state flag
			}
			L {
				set L $arg
				set state flag
			}
			W {
				set W $arg
				set state flag
			}
		}
	}
}

#array set instances $inst

#--------------------------------------------------
# Open output file
#-------------------------------------------------- 
set fh_out [open $out "w"]
#--------------------------------------------------
# Open csv file
#-------------------------------------------------- 
set fh_csv [open $csv "r"]
#--------------------------------------------------
# Open instances files
#-------------------------------------------------- 
foreach inst_file $inst {
	set fh_${inst_file} [open $inst_file "r"]
}


while {[gets $fh_csv matrix] >= 0} {
	foreach neo [split $matrix ,] {
		if {[string length $neo] > 0} {
			set fh_current fh_${neo}
			gets [subst $$fh_current] instance
			puts $fh_out "lakerFindObj -index 1 -type Transistor -searProp {Instance == {$instance}}"
			puts $fh_out "lakerAttribute -index 1 -point ($X,$Y) -inst $instance"
			set X [expr $X + [expr $L + 0.84]]
#			puts -nonewline $fh_out "$instance,"
		} else {
			set X [expr $X + [expr $L + 0.84]]
#			puts -nonewline $fh_out "_,"
		}
	}
	set X 0
	set Y [expr $Y + [expr $W + $usr_space]]
	puts $fh_out "\n"
}

close $fh_csv
foreach inst_file $inst {
	set fh_tmp fh_${inst_file}
	close [subst $$fh_tmp]
}







