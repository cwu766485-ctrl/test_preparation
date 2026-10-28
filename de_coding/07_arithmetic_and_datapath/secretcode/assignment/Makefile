VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps
TOP := tb_secret_code
TOPS := tb_secret_code
BUILD := build
RTL := rtl/secret_code_m.v rtl/secret_code_four.v rtl/secret_code_single.v
TB := tb/tb_secret_code.sv

.PHONY: all test gui clean
all: test

test:
	@mkdir -p $(BUILD)
	cd $(BUILD) && $(VCS) $(VCS_FLAGS) -top $(TOP) $(addprefix ../,$(RTL) $(TB)) -o simv -l compile.log
	cd $(BUILD) && ./simv -l sim.log
	@grep '^PASS:' $(BUILD)/sim.log

test_$(TOP): test

gui: test
	cd $(BUILD) && ./simv -gui

clean:
	rm -rf $(BUILD)
