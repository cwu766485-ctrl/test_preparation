# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := carry_lookahead_adder
TEST_TARGETS := test_carry_lookahead_adder

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_carry_lookahead_adder:
	@mkdir -p $(BUILD)/carry_lookahead_adder
	cd $(BUILD)/carry_lookahead_adder && $(VCS) $(VCS_FLAGS) -top tb_carry_lookahead_adder_smoke $(ROOT)/carry_lookahead_adder.v $(ROOT)/tb_carry_lookahead_adder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
