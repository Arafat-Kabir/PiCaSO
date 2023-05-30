# Contraints
set period 1.8518
create_clock -period $period -name clk [get_ports clk]

set_property DONT_TOUCH true [get_cells ALU]
