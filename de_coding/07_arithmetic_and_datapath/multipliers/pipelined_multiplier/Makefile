# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := multiplier_adder_tree pipelined_multiplier
TEST_TARGETS := test_multiplier_adder_tree test_pipelined_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_multiplier_adder_tree:
	@mkdir -p $(BUILD)/multiplier_adder_tree
	cd $(BUILD)/multiplier_adder_tree && $(VCS) $(VCS_FLAGS) -top tb_multiplier_adder_tree_smoke $(ROOT)/multiplier_adder_tree.v $(ROOT)/tb_multiplier_adder_tree_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_pipelined_multiplier:
	@mkdir -p $(BUILD)/pipelined_multiplier
	cd $(BUILD)/pipelined_multiplier && $(VCS) $(VCS_FLAGS) -top tb_pipelined_multiplier_smoke $(ROOT)/multiplier_adder_tree.v $(ROOT)/pipelined_multiplier.v $(ROOT)/tb_pipelined_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
