# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := logical_shifter
TEST_TARGETS := test_logical_shifter

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_logical_shifter:
	@mkdir -p $(BUILD)/logical_shifter
	cd $(BUILD)/logical_shifter && $(VCS) $(VCS_FLAGS) -top tb_logical_shifter_smoke $(ROOT)/logical_shifter.v $(ROOT)/tb_logical_shifter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
