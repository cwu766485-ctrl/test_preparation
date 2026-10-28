# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := array_multiplier
TEST_TARGETS := test_array_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_array_multiplier:
	@mkdir -p $(BUILD)/array_multiplier
	cd $(BUILD)/array_multiplier && $(VCS) $(VCS_FLAGS) -top tb_array_multiplier_smoke $(ROOT)/../../adders/full_adder/full_adder.v $(ROOT)/../../adders/ripple_carry_adder/ripple_carry_adder.v $(ROOT)/array_multiplier.v $(ROOT)/tb_array_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
