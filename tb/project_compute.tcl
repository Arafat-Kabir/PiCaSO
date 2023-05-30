set device 		 "xc7vx485tffg1761-2"
set project_name "prj_compute01"
set includepath  {../lib}
set modules 	 {  
    ../lib/Compute.v
    ../lib/ComputeControl.v
    ../lib/ComputeInterconnect.v

    ../lib/network/DataNetNode.v
    ../lib/network/bus_mux.v
    ../lib/network/bus_muxp.v
    ../lib/network/mux.v
    ../lib/network/mux_pair.v
    ../lib/network/Receiver.v
    ../lib/network/Register.v
    ../lib/network/RouterNEWS.v
    ../lib/network/Transmitter.v
    ../lib/opmux/opmux_behav.v
    ../lib/regfile/bram_wrfirst_ff.v
    ../lib/regfile/bram_wrfirst_noff.v
    ../lib/alu/alu_serial.v
    ../lib/alu/alu_serial_unit.v
    ../lib/alu/boothR2_serial_alu.v
}
#set testbench 	 { ../tb/tb_bus_mux_vivado.v }
set  constrpath "../tb/constraints.xdc"

# Some internal variables
set ext_       ".xpr"
set prj_name_  $project_name$ext_          ;# adding extension to the project name

# Create project
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
create_fileset -blockset -define_from alu_serial_unit alu_serial_unit
add_files -fileset alu_serial_unit  ../tb/alu-unit-ooc-contr.xdc
set_property USED_IN {out_of_context synthesis implementation}  [get_files  ../tb/alu-unit-ooc-contr.xdc]



start_gui
