# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := shift_add_multiplier
TEST_TARGETS := test_shift_add_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_shift_add_multiplier:
	@mkdir -p $(BUILD)/shift_add_multiplier
	cd $(BUILD)/shift_add_multiplier && $(VCS) $(VCS_FLAGS) -top tb_shift_add_multiplier_smoke $(ROOT)/shift_add_multiplier.v $(ROOT)/tb_shift_add_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
