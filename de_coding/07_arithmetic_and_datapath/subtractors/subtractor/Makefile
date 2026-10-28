# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := subtractor
TEST_TARGETS := test_subtractor

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_subtractor:
	@mkdir -p $(BUILD)/subtractor
	cd $(BUILD)/subtractor && $(VCS) $(VCS_FLAGS) -top tb_subtractor_smoke $(ROOT)/subtractor.v $(ROOT)/tb_subtractor_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
