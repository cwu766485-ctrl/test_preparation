VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOP := tb_seq_multiplier8
RTL := rtl/seq_multiplier8.v
TB := tb/tb_seq_multiplier8.sv
EXPECT := PASS Mock4 seq_multiplier8

.PHONY: test clean

test:
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) $(ROOT)/$(RTL) $(ROOT)/$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	cd $(BUILD) && grep -Fq '$(EXPECT)' sim.log

clean:
	rm -rf $(BUILD)