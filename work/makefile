
# Making receipes as unconditional commands
.PHONY: list 


list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'




# Recipe templates
compile:
	@iverilog    -I ../lib \
			     -I ../lib/alu/  \
			     -I ../lib/network/  \
			     -I ../lib/opmux/  \
			     -I ../lib/regfile/  \
				 \
				 -l ../lib/Compute.v \
				 -l ../tb/Compute_allff.v \
				 -l ../lib/ComputeControl.v  \
				 -l ../lib/ComputeInterconnect.v  \
				 -l ../lib/network/DataNetNode.v  \
			     -l ../lib/network/bus_mux.v     \
				 -l	../lib/network/bus_muxp.v  \
				 -l	../lib/network/mux.v  \
				 -l	../lib/network/mux_pair.v  \
				 -l	../lib/network/Receiver.v  \
				 -l	../lib/network/Register.v  \
				 -l	../lib/network/RouterNEWS.v  \
				 -l	../lib/network/Transmitter.v  \
				 -l ../lib/opmux/opmux_behav.v  \
				 -l ../lib/opmux/opmux_behav_ff.v  \
				 -l ../lib/regfile/bram_wrfirst_ff.v  \
				 -l ../lib/alu/alu_serial.v  \
				 -l ../lib/alu/alu_serial_unit.v  \
				 -l ../lib/alu/alu_serial_ff.v  \
				 -l ../lib/alu/boothR2_serial_alu.v  \
				 -o compute-test.vvp \
				 ../tb/tb_Compute_ivl02.v

analyze: analyze_compute  analyze_control  analyze_intercon


project:
	@vivado -mode batch -source ../tb/project_compute.tcl


# Check syntax
analyze_compute:
	xvlog --include ../lib/   ../lib/Compute.v

analyze_control:
	xvlog ../lib/ComputeControl.v

analyze_intercon:
	xvlog ../lib/ComputeInterconnect.v

analyze_versions:
	xvlog --include ../lib/   ../tb/Compute_atiyehEq.v \
	                          ../tb/Compute_rfff.v \
	                          ../tb/Compute_allff.v \
	                          ../tb/Compute_opff.v


# Different version of PE-16 block
project_atiyeh:
	@vivado -mode batch -source ../tb/project_atiyeh.tcl

project_atEq:
	@vivado -mode batch -source ../tb/project_compute_atiyeEq.tcl

project_rfff:
	@vivado -mode batch -source ../tb/project_compute_rfff.tcl

project_allff:
	@vivado -mode batch -source ../tb/project_compute_allff.tcl

project_opff:
	@vivado -mode batch -source ../tb/project_compute_opff.tcl


# 2D arrays of Different version of PE-16 block
project_atiyeh2D:
	@vivado -mode batch -source ../tb/project_atiyeh2D.tcl

analyze_atiyeh2D:
	@xvlog --include ../lib/   ../tb/atiyeh-pe16/array2D_atiyeh.v


project_allff2D:
	@vivado -mode batch -source ../tb/project_allff2D.tcl

analyze_allff2D:
	@xvlog --include ../lib/   ../tb/array2D_allff.v


project_atEq2D:
	@vivado -mode batch -source ../tb/project_atEq2D.tcl

analyze_atEq2D:
	@xvlog --include ../lib/   ../tb/array2D_atEq.v


project_rfff2D:
	@vivado -mode batch -source ../tb/project_rfff2D.tcl

analyze_rfff2D:
	@xvlog --include ../lib/   ../tb/array2D_rfff.v


project_opff2D:
	@vivado -mode batch -source ../tb/project_opff2D.tcl

analyze_opff2D:
	@xvlog --include ../lib/   ../tb/array2D_opff.v


# Clean up commands
clean_all: clean_projects
	rm -rf *.csv *.vvp *.vcd *.log *.out
	rm -rf vivado*.zip  xsim.dir xvlog.pb 

clean_projects:
	rm -rf *.xpr *.jou \
		   prj*.cache  \
		   prj*.hw \
		   prj*.ip_user_files \
		   prj*.runs \
		   prj*.sim \
		   prj*.srcs \
		   prj*.ioplanning \
		   .Xil



