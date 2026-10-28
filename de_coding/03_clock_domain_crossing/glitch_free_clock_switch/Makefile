# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := glitch_free_clock_switch glitch_free_clock_switch_ownership
TEST_TARGETS := test_glitch_free_clock_switch test_glitch_free_clock_switch_ownership

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_glitch_free_clock_switch:
	@mkdir -p $(BUILD)/glitch_free_clock_switch
	cd $(BUILD)/glitch_free_clock_switch && $(VCS) $(VCS_FLAGS) -top tb_glitch_free_clock_switch_smoke $(ROOT)/glitch_free_clock_switch.v $(ROOT)/tb_glitch_free_clock_switch_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_glitch_free_clock_switch_ownership:
	@mkdir -p $(BUILD)/glitch_free_clock_switch_ownership
	cd $(BUILD)/glitch_free_clock_switch_ownership && $(VCS) $(VCS_FLAGS) -top tb_glitch_free_clock_switch_ownership_smoke $(ROOT)/glitch_free_clock_switch.v $(ROOT)/tb_glitch_free_clock_switch_ownership_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
