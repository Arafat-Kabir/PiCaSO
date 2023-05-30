set device 		 "xc7vx485tffg1761-2"
set project_name "prj_atiyeh2D_01"
set includepath  {../../tb/atiyeh-pe16}
set modules 	 {  
    ../../tb/atiyeh-pe16/array2D_atiyeh.v
    ../../tb/atiyeh-pe16/BRAM.v
    ../../tb/atiyeh-pe16/PE16_Block.v
    ../../tb/atiyeh-pe16/Serialized_ALU.v
}
#set testbench 	 { ../tb/tb_bus_mux_vivado.v }
set  constrpath "../../tb/atiyeh-pe16/constraints_2D.xdc"

# Some internal variables
set ext_       ".xpr"
set prj_name_  $project_name$ext_          ;# adding extension to the project name

# Create project under a subdirectory
exec mkdir "$project_name"
cd "$project_name"
create_project $prj_name_
set_property part $device [current_project]
set_property include_dirs $includepath [current_fileset]
add_files -fileset sources_1 -norecurse $modules
#add_files -fileset sim_1     -norecurse $testbench
add_files -fileset constrs_1 -norecurse $constrpath

set_property SOURCE_SET sources_1 [get_filesets sim_1]
#update_compile_order -fileset sim_1
update_compile_order -fileset sources_1




start_gui
