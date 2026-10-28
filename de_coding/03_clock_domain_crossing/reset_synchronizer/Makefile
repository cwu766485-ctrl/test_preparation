# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := dual_clock_reset_sync reset_synchronizer
TEST_TARGETS := test_dual_clock_reset_sync test_reset_synchronizer

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_dual_clock_reset_sync:
	@mkdir -p $(BUILD)/dual_clock_reset_sync
	cd $(BUILD)/dual_clock_reset_sync && $(VCS) $(VCS_FLAGS) -top tb_dual_clock_reset_sync_smoke $(ROOT)/dual_clock_reset_sync.v $(ROOT)/reset_synchronizer.v $(ROOT)/tb_dual_clock_reset_sync_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_reset_synchronizer:
	@mkdir -p $(BUILD)/reset_synchronizer
	cd $(BUILD)/reset_synchronizer && $(VCS) $(VCS_FLAGS) -top tb_reset_synchronizer_smoke $(ROOT)/reset_synchronizer.v $(ROOT)/tb_reset_synchronizer_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
