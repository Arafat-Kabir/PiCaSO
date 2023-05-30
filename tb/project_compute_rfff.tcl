set device 		 "xc7vx485tffg1761-2"
set project_name "prj_compute_rfff01"
set includepath  {../../lib}
set modules 	 {  
    ../../tb/Compute_rfff.v
    ../../tb/wrap_bram_wrfirst_ff.v

    ../../lib/ComputeControl.v
    ../../lib/ComputeInterconnect.v

    ../../lib/network/DataNetNode.v
    ../../lib/network/bus_mux.v
    ../../lib/network/bus_muxp.v
    ../../lib/network/mux.v
    ../../lib/network/mux_pair.v
    ../../lib/network/Receiver.v
    ../../lib/network/Register.v
    ../../lib/network/RouterNEWS.v
    ../../lib/network/Transmitter.v
    ../../lib/opmux/opmux_behav.v
    ../../lib/regfile/bram_wrfirst_ff.v
    ../../lib/regfile/bram_wrfirst_noff.v
    ../../lib/alu/alu_serial.v
    ../../lib/alu/alu_serial_unit.v
    ../../lib/alu/boothR2_serial_alu.v
}
#set testbench 	 { ../tb/tb_bus_mux_vivado.v }
set  constrpath "../../tb/constraints-rfff.xdc"

# Some internal variables
set ext_       ".xpr"
set prj_name_  $project_name$ext_          ;# adding extension to the project name

# Create project
exec mkdir "$project_name"
cd   "$project_name"
create_project $prj_name_
set_property part $device [current_project]
set_property include_dirs $includepath [current_fileset]
add_files -fileset sources_1 -norecurse $modules
#add_files -fileset sim_1     -norecurse $testbench
add_files -fileset constrs_1 -norecurse $constrpath

set_property SOURCE_SET sources_1 [get_filesets sim_1]
#update_compile_order -fileset sim_1
update_compile_order -fileset sources_1


# Speical settings
# Set alu_unit as out-of-context synthesis module
set ooc_contr "../../tb/alu-unit-ooc-contr.xdc"
create_fileset -blockset -define_from alu_serial_unit alu_serial_unit
add_files -fileset alu_serial_unit  $ooc_contr
set_property USED_IN {out_of_context synthesis implementation}  [get_files  $ooc_contr]

set ooc_contr "../../tb/bram-ff-wrap-ooc-contr.xdc"
create_fileset -blockset -define_from wrap_bram_wrfirst_ff wrap_bram_wrfirst_ff
add_files -fileset wrap_bram_wrfirst_ff $ooc_contr
set_property USED_IN {out_of_context synthesis implementation}  [get_files  $ooc_contr]

set_property top Compute_rfff [current_fileset]
update_compile_order -fileset sources_1



start_gui
