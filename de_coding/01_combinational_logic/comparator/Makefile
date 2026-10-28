# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := comparator
TEST_TARGETS := test_comparator

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_comparator:
	@mkdir -p $(BUILD)/comparator
	cd $(BUILD)/comparator && $(VCS) $(VCS_FLAGS) -top tb_comparator_smoke $(ROOT)/comparator.v $(ROOT)/tb_comparator_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
