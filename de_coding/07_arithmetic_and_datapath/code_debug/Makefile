VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
TOP := tb_code_debug
RTL := code_debug_shift_reg.v buggy_shift_reg.v
TB := tb_code_debug.v
BUILD := build

.PHONY: all test clean
all: test

test:
	@mkdir -p $(BUILD)
	$(VCS) $(VCS_FLAGS) -Mdir=$(BUILD)/csrc -top $(TOP) $(RTL) $(TB) -o $(BUILD)/simv -l $(BUILD)/compile.log
	./$(BUILD)/simv -l $(BUILD)/run.log
	@grep -q '^PASS:' $(BUILD)/run.log
	@grep '^PASS:' $(BUILD)/run.log

clean:
	rm -rf $(BUILD)
