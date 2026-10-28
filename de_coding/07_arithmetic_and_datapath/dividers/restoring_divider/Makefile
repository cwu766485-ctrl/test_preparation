# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := restoring_divider
TEST_TARGETS := test_restoring_divider

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_restoring_divider:
	@mkdir -p $(BUILD)/restoring_divider
	cd $(BUILD)/restoring_divider && $(VCS) $(VCS_FLAGS) -top tb_restoring_divider_smoke $(ROOT)/restoring_divider.v $(ROOT)/tb_restoring_divider_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
