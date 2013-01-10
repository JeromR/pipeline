proc afrender {args} {
   set nameaf [lindex $args 0]
   set writer [input $nameaf 0]
   set namewrite [knob $writer.name]
   if {[class $writer] != "Write"} {
      alert "Node class $namewrite is not Write"
      return}
   if {[knob $writer.disable] == true} {
      alert "Node $namewrite is disabled"
      return}
   set images [knob $writer.file]

   knob $writer.beforeRender ""
   knob $writer.afterRender ""

   set first         [lindex $args  1]
   set last          [lindex $args  2]
   set fpr           [lindex $args  3]
   set startpaused   [lindex $args  4]
   set priority      [lindex $args  5]
   set maxhosts      [lindex $args  6]
   set hostsmask     [lindex $args  7]
   set hostsexcl     [lindex $args  8]
   set dependmask    [lindex $args  9]
   set dependglbl    [lindex $args 10]
   set jobname       [lindex $args 11]
   set capacity      [lindex $args 12]
   set capmin        [lindex $args 13]
   set capmax        [lindex $args 14]

   if {$first > $last} {
      alert "First frame > Last frame"
      return}
   if {$fpr < 1} {
      alert "Frames per render - must be > 0"
      return}
      
   
   set cpipeline_path [getenv CPIPELINE]
   puts $cpipeline_path
   append cpipeline_path "/bin/afnuke"
   
   set current_script_name [knob root.name]
   script_save $current_script_name
   catch { exec $cpipeline_path [knob root.name] } result
   set namesc [knob root.name]
   if { $result != "none" } {
        puts  $current_script_name
        set namesctmp $result
   } else {
    set namesctmp "tmp."
    set namesctmp $namesc
    set namesc [regsub {.*/} $namesc ""]
    append namesctmp [clock format [clock seconds] -format %d-%m-%Y.%H-%M.[string range [clock clicks] 3 6]]
    append namesctmp \.nk
    script_save $namesctmp
   }
   set changed [modified]
   modified $changed
   
   puts $result
   puts $namesctmp
   
   if { $jobname == ""} {
      set jobname $namesc
   }

   regsub -all "\\\\" $namesctmp "/" namesctmp

   set cmd [getenv AF_ROOT]
   set cmd [file join $cmd "python"]
   set cmd [file join $cmd "afjob.py"]
   set cmd "python $cmd"
   append cmd " $namesctmp $first $last -fpr $fpr -node $namewrite -name \"$jobname\" -images \"$images\"  -nuke6"

   if { $startpaused      } { append cmd " -startpaused"                }
   if { $maxhosts   != -1 } { append cmd " -maxhosts $maxhosts"         }
   if { $priority   != -1 } { append cmd " -priority $priority"         }
   if { $capacity   != -1 } { append cmd " -capacity $capacity"         }
   if { $capmin     != -1 } { append cmd " -capmin $capmin"             }
   if { $capmax     != -1 } { append cmd " -capmax $capmax"             }
   if { $hostsmask  != "" } { append cmd " -hostsmask \"$hostsmask\""   }
   if { $hostsexcl  != "" } { append cmd " -hostsexcl \"$hostsexcl\""   }
   if { $dependmask != "" } { append cmd " -depmask \"$dependmask\""    }
   if { $dependglbl != "" } { append cmd " -depglbl \"$dependglbl\""    }

   puts $cmd
   
   #######
   eval exec $cmd
}
