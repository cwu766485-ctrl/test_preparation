# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := prefix_adder prefix_adder_stage
TEST_TARGETS := test_prefix_adder test_prefix_adder_stage

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_prefix_adder:
	@mkdir -p $(BUILD)/prefix_adder
	cd $(BUILD)/prefix_adder && $(VCS) $(VCS_FLAGS) -top tb_prefix_adder_smoke $(ROOT)/prefix_adder.v $(ROOT)/prefix_adder_stage.v $(ROOT)/tb_prefix_adder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_prefix_adder_stage:
	@mkdir -p $(BUILD)/prefix_adder_stage
	cd $(BUILD)/prefix_adder_stage && $(VCS) $(VCS_FLAGS) -top tb_prefix_adder_stage_smoke $(ROOT)/prefix_adder_stage.v $(ROOT)/tb_prefix_adder_stage_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
