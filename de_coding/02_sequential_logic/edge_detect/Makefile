# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := edge_detect
TEST_TARGETS := test_edge_detect

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_edge_detect:
	@mkdir -p $(BUILD)/edge_detect
	cd $(BUILD)/edge_detect && $(VCS) $(VCS_FLAGS) -top tb_edge_detect_smoke $(ROOT)/edge_detect.v $(ROOT)/tb_edge_detect_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
