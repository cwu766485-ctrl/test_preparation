# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := barrel_shifter
TEST_TARGETS := test_barrel_shifter

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_barrel_shifter:
	@mkdir -p $(BUILD)/barrel_shifter
	cd $(BUILD)/barrel_shifter && $(VCS) $(VCS_FLAGS) -top tb_barrel_shifter_smoke $(ROOT)/barrel_shifter.v $(ROOT)/tb_barrel_shifter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
