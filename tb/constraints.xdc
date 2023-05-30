# Contraints
set period 3.70
create_clock -period $period -name clk [get_ports clk]

set_property DONT_TOUCH true [get_cells ALU]
