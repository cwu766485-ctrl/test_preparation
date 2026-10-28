# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := seg_scan
TEST_TARGETS := test_seg_scan

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_seg_scan:
	@mkdir -p $(BUILD)/seg_scan
	cd $(BUILD)/seg_scan && $(VCS) $(VCS_FLAGS) -top tb_seg_scan_smoke $(ROOT)/seven_segment_scan.v $(ROOT)/tb_seg_scan_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
