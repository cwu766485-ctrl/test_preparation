# Requires LOCAL GF22 library .synopsys_dc.setup and common_setup_gf22.tcl.
# Run with current directory = .../mock3_sequential_matrix_mul_2x2/synth
current_design matrix_mul_2x2
link
check_design

# The mock question requires a 10ns clock (NOT the Module4 100ns clock).
create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

# Explicit illustrative IO constraints; replace according to lab guidance.
set data_inputs [remove_from_collection [all_inputs] [get_ports clk]]
set data_inputs [remove_from_collection $data_inputs [get_ports rst_n]]
set_input_delay 0.5 -clock clk $data_inputs
set_output_delay 0.5 -clock clk [all_outputs]

compile
check_design

file mkdir netlist
file mkdir logs
write -format verilog -hierarchy -output netlist/Syn_matrix_mul_2x2.v
write_sdf netlist/Syn_matrix_mul_2x2.sdf
write_sdc netlist/Syn_matrix_mul_2x2.sdc

redirect -file logs/area.rpt      { report_area }
redirect -file logs/reference.rpt { report_reference }
redirect -file logs/timing.rpt    { report_timing -delay_type max -max_paths 10 }
redirect -file logs/qor.rpt       { report_qor }
redirect -file logs/check.rpt     { check_design }
redirect -file logs/power_unannotated.rpt { report_power }
# Report actual paths, slack and cell counts from reports;
# power_unannotated.rpt is NOT a measured SAIF-driven power result.
