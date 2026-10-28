# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := clk_div_even
TEST_TARGETS := test_clk_div_even

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_clk_div_even:
	@mkdir -p $(BUILD)/clk_div_even
	cd $(BUILD)/clk_div_even && $(VCS) $(VCS_FLAGS) -top tb_clk_div_even_smoke $(ROOT)/even_divider.v $(ROOT)/tb_clk_div_even_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
