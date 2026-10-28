# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := glitch_free_clk_mux
TEST_TARGETS := test_glitch_free_clk_mux

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_glitch_free_clk_mux:
	@mkdir -p $(BUILD)/glitch_free_clk_mux
	cd $(BUILD)/glitch_free_clk_mux && $(VCS) $(VCS_FLAGS) -top tb_glitch_free_clk_mux_smoke $(ROOT)/glitch_free_clock_mux.v $(ROOT)/tb_glitch_free_clk_mux_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
