# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := booth_multiplier
TEST_TARGETS := test_booth_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_booth_multiplier:
	@mkdir -p $(BUILD)/booth_multiplier
	cd $(BUILD)/booth_multiplier && $(VCS) $(VCS_FLAGS) -top tb_booth_multiplier_smoke $(ROOT)/booth_multiplier.v $(ROOT)/tb_booth_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
