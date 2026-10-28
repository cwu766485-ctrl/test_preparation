VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
TOP := tb_seq_det_101_moore
RTL := seq_det_101_moore.v
TB := tb_seq_det_101_moore.v
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
