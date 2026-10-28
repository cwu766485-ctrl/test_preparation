# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := add_sub_unit
TEST_TARGETS := test_add_sub_unit

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_add_sub_unit:
	@mkdir -p $(BUILD)/add_sub_unit
	cd $(BUILD)/add_sub_unit && $(VCS) $(VCS_FLAGS) -top tb_add_sub_unit_smoke $(ROOT)/add_sub_unit.v $(ROOT)/tb_add_sub_unit_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
