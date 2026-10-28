# VCS tests for the three counter behaviors.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
SV_FLAGS ?= -full64 -sverilog -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TEST_TARGETS := test_cnt_up test_cnt_down test_cnt_modN

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_cnt_up:
	@mkdir -p $(BUILD)/cnt_up/verilog $(BUILD)/cnt_up/systemverilog
	cd $(BUILD)/cnt_up/verilog && $(VCS) $(VCS_FLAGS) -top tb_cnt_up $(ROOT)/counters.v $(ROOT)/tb_cnt_up.v -o simv && ./simv
	cd $(BUILD)/cnt_up/systemverilog && $(VCS) $(SV_FLAGS) -top tb_cnt_up $(ROOT)/counters.sv $(ROOT)/tb_cnt_up.v -o simv && ./simv

test_cnt_down:
	@mkdir -p $(BUILD)/cnt_down/verilog $(BUILD)/cnt_down/systemverilog
	cd $(BUILD)/cnt_down/verilog && $(VCS) $(VCS_FLAGS) -top tb_cnt_down $(ROOT)/counters.v $(ROOT)/tb_cnt_down.v -o simv && ./simv
	cd $(BUILD)/cnt_down/systemverilog && $(VCS) $(SV_FLAGS) -top tb_cnt_down $(ROOT)/counters.sv $(ROOT)/tb_cnt_down.v -o simv && ./simv

test_cnt_modN:
	@mkdir -p $(BUILD)/cnt_modN/verilog $(BUILD)/cnt_modN/systemverilog
	cd $(BUILD)/cnt_modN/verilog && $(VCS) $(VCS_FLAGS) -top tb_cnt_modN $(ROOT)/counters.v $(ROOT)/tb_cnt_modN.v -o simv && ./simv
	cd $(BUILD)/cnt_modN/systemverilog && $(VCS) $(SV_FLAGS) -top tb_cnt_modN $(ROOT)/counters.sv $(ROOT)/tb_cnt_modN.v -o simv && ./simv

clean:
	rm -rf $(BUILD)
