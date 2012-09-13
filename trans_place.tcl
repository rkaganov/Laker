#!/bin/sh  
# \
exec tclsh "$0" ${1+"$@"}

$Id:$

#--------------------------------------------------
# Global variables
#-------------------------------------------------- 
set state flag
set start_X 0
set start_Y 0

proc Help {} {
	puts {}
	puts "Usage:"
	puts {}
	puts " -csv       : csv file                                 "
	puts " -inst      : A B C ... X                              "
	puts " -usr_space : user space value                         "
	puts " -L         : Transistor L                             "
	puts " -W         : Transistor W                             "
	puts " -start_X   : Starting X coordinate. Default is \"0\"  "
	puts " -start_Y   : Starting Y coordinate. Default is \"0\"  "
	puts " -out       : Output file                              "
	puts {}

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
					-start_X   { set state start_X   }
					-start_Y   { set state start_Y   }
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
			start_X {
				set start_X $arg
				set state flag
			}
			start_Y {
				set start_Y $arg
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

set X $start_X
set Y $start_Y

while {[gets $fh_csv matrix] >= 0} {
	foreach neo [split $matrix ,] {
		if {[string length $neo] > 0} {
			set fh_current fh_${neo}
			gets [subst $$fh_current] instance
			puts $fh_out "lakerFindObj -index 1 -type Transistor -searProp {Instance == {$instance}}"
			puts $fh_out "lakerAttribute -index 1 -point ($X,$Y) -inst $instance"
#			puts -nonewline $fh_out "$instance,"
		}
		set X [expr $X + [expr $L + 0.84]]
		set X [format %#.2f $X]
	}
	set X $start_X
	set Y [expr $Y + [expr $W + $usr_space]]
	set Y [format %#.2f $Y]
	puts $fh_out "\n"
}

close $fh_csv
foreach inst_file $inst {
	set fh_tmp fh_${inst_file}
	close [subst $$fh_tmp]
}







