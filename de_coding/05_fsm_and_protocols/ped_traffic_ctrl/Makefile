VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOP := tb_ped_traffic_ctrl
RTL := rtl/ped_traffic_ctrl.v
TB := tb/tb_ped_traffic_ctrl.sv
EXPECT := PASS Mock5 ped_traffic_ctrl

.PHONY: test clean

test:
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) $(ROOT)/$(RTL) $(ROOT)/$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	cd $(BUILD) && grep -Fq '$(EXPECT)' sim.log

clean:
	rm -rf $(BUILD)