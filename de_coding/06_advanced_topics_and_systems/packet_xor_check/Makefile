VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOP := tb_packet_xor_check
RTL := rtl/packet_xor_check.v
TB := tb/tb_packet_xor_check.sv
EXPECT := PASS Mock7 packet_xor_check

.PHONY: test clean

test:
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) $(ROOT)/$(RTL) $(ROOT)/$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	cd $(BUILD) && grep -Fq '$(EXPECT)' sim.log

clean:
	rm -rf $(BUILD)