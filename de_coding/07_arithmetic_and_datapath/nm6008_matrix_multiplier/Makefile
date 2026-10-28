VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
TOP := MatrixMultiplier_tb
TOPS := MatrixMultiplier_tb
BUILD := build
RTL := MatrixMultiplier.v
TB := MatrixMultiplier_tb.sv

.PHONY: all test gui clean
all: test

test:
	@mkdir -p $(BUILD)
	cp InputVector.txt $(BUILD)/InputVector.txt
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) ../$(RTL) ../$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	@grep '^PASS:' $(BUILD)/sim.log

test_$(TOP): test

gui:
	@mkdir -p $(BUILD)
	cp InputVector.txt $(BUILD)/InputVector.txt
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) ../$(RTL) ../$(TB) -o simv -l compile.log
	cd $(BUILD) && ./simv -gui

clean:
	rm -rf $(BUILD)
