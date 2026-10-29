# MOCK SYNTHESIS TEMPLATE - requires locally authorized GF22 .db setup.
# Current working directory must be this exercise's synth folder.
current_design uart_tx8
link
check_design
create_clock -name CLK -period 10 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks CLK]
set input_ports [remove_from_collection [all_inputs] [get_ports clk]]
set input_ports [remove_from_collection $input_ports [get_ports rst_n]]
set_input_delay 0.5 -clock CLK $input_ports
set_output_delay 0.5 -clock CLK [all_outputs]
compile
check_design
file mkdir netlist
file mkdir logs
write -format verilog -hierarchy -output netlist/Syn_uart_tx8.v
write_sdf netlist/Syn_uart_tx8.sdf
write_sdc netlist/Syn_uart_tx8.sdc
redirect -file logs/area.rpt { report_area }
redirect -file logs/reference.rpt { report_reference }
redirect -file logs/timing.rpt { report_timing -delay_type max -max_paths 10 }
redirect -file logs/qor.rpt { report_qor }
redirect -file logs/check.rpt { check_design }
# This unannotated report is NOT a SAIF-driven power measurement.
redirect -file logs/power_unannotated.rpt { report_power }
