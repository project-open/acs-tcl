ad_library {

    This file includes various hacks to make OpenACS work on Windows.
    Replaces the TCL exec command on Windows, allowing exec to be called with unix-y arguments.
    <OL>
      <LI> The command is supposed to be in $AOLDIR/bin. If not, it only uses the tail, relying on the PATH.
      <LI> If stderr is being redirected to /dev/null, it actually gets redirected to nul.
      <LI> This didn't work in early AOLserver 4.0 beta builds as rename was broken.
    </OL>

    @author jrasmuss@mle.ie
    @author Maurizio.Martignano@acm.org
}

global tcl_platform 
if { ![string match $tcl_platform(platform) "windows"] } {
    ns_log notice "/acs-tcl/tcl/windows-procs.tcl: Running on Linux - Disabling exec hack"
    return
}
ns_log notice "/acs-tcl/tcl/windows-procs.tcl: Running on Windows - Enabling exec hack"

rename ::exec ::exec_orig

proc exec {args} {
    # Processing program name
    set procname [lindex $args 0]
    set args [lrange $args 1 end]
    set procname [file tail ${procname}]


    # find out the base path
    set unixaoldir ""
    if {[info exists ::env(AOLDIR)]} {
	set winaoldir $::env(AOLDIR)
	set unixaoldir [string map {\\ /} ${winaoldir}]
    } else {
	set pageroot [acs_root_dir]
	# Something like c:/project-open/servers/projop
	set pageroot_pieces [split $pageroot "/"]
	set pos [lsearch $pageroot_pieces "servers"]
	if {$pos > 0} {
	    set unixaoldir [join [lrange $pageroot_pieces 0 $pos-1] "/"]
	}
    }
    ns_log Notice "exec: unixaoldir=$unixaoldir"


    if {[file exists ${unixaoldir}/bin/${procname}.exe]} {
      set procname ${unixaoldir}/bin/${procname}
    }
    if {[file exists ${unixaoldir}/bin/${procname}.bat]} {
      set procname ${unixaoldir}/bin/${procname}
    }

    #Processing its arguments 
    for {set i 0} {$i < [llength $args]} {incr i} {
        if {[string match [lindex $args $i] "2>/dev/null"]} {
            set args [lreplace $args $i $i "2>nul"]
        }
    }

    #Calling original exec
    set cmd "::exec_orig $procname $args"
    return [eval $cmd]
}

