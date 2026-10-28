# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := carry_select_adder
TEST_TARGETS := test_carry_select_adder

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_carry_select_adder:
	@mkdir -p $(BUILD)/carry_select_adder
	cd $(BUILD)/carry_select_adder && $(VCS) $(VCS_FLAGS) -top tb_carry_select_adder_smoke $(ROOT)/carry_select_adder.v $(ROOT)/tb_carry_select_adder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
