# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := wallace_compressor_tree wallace_multiplier
TEST_TARGETS := test_wallace_compressor_tree test_wallace_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_wallace_compressor_tree:
	@mkdir -p $(BUILD)/wallace_compressor_tree
	cd $(BUILD)/wallace_compressor_tree && $(VCS) $(VCS_FLAGS) -top tb_wallace_compressor_tree_smoke $(ROOT)/wallace_compressor_tree.v $(ROOT)/tb_wallace_compressor_tree_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_wallace_multiplier:
	@mkdir -p $(BUILD)/wallace_multiplier
	cd $(BUILD)/wallace_multiplier && $(VCS) $(VCS_FLAGS) -top tb_wallace_multiplier_smoke $(ROOT)/wallace_compressor_tree.v $(ROOT)/wallace_multiplier.v $(ROOT)/tb_wallace_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
