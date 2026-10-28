# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := traffic_fsm
TEST_TARGETS := test_traffic_fsm

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_traffic_fsm:
	@mkdir -p $(BUILD)/traffic_fsm
	cd $(BUILD)/traffic_fsm && $(VCS) $(VCS_FLAGS) -top tb_traffic_fsm_smoke $(ROOT)/traffic_fsm_moore.v $(ROOT)/tb_traffic_fsm_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
