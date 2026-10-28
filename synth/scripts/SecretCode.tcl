# To be sourced from Design Vision after local lab .synopsys_dc.setup
current_design secret_code_four
link
check_design
create_clock -name CLK -period 100 [get_ports clk]
set_clock_uncertainty 0.5 [get_clocks CLK]
set_input_delay 1 -clock CLK [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1 -clock CLK [all_outputs]
compile
file mkdir netlist
file mkdir logs
write -format verilog -hierarchy -output netlist/Syn_secret_code_four.v
write_sdf netlist/Syn_secret_code_four.sdf
write_sdc netlist/Syn_secret_code_four.sdc
redirect -file logs/report.rpt {
    report_area
    report_reference
    report_timing -max_paths 10
    report_constraints -all_violators
    report_qor
}
