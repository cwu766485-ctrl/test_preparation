VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
TOPS := tb_Test2
BUILD := build
RTL := Test2.v
TB := Test2_tb.v

.PHONY: all test test_tb_Test2 clean
all: test

test: test_tb_Test2

test_tb_Test2:
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOPS) ../$(RTL) ../$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	@grep '^PASS:' $(BUILD)/sim.log

clean:
	rm -rf $(BUILD)
