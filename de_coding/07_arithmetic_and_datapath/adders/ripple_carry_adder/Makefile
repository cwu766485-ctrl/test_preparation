# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := ripple_carry_adder
TEST_TARGETS := test_ripple_carry_adder

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_ripple_carry_adder:
	@mkdir -p $(BUILD)/ripple_carry_adder
	cd $(BUILD)/ripple_carry_adder && $(VCS) $(VCS_FLAGS) -top tb_ripple_carry_adder_smoke $(ROOT)/../full_adder/full_adder.v $(ROOT)/ripple_carry_adder.v $(ROOT)/tb_ripple_carry_adder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
