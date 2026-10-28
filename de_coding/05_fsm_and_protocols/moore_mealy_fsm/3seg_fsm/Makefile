# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := fsm_3seg
TEST_TARGETS := test_fsm_3seg

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_fsm_3seg:
	@mkdir -p $(BUILD)/fsm_3seg
	cd $(BUILD)/fsm_3seg && $(VCS) $(VCS_FLAGS) -top tb_fsm_3seg_smoke $(ROOT)/fsm_3seg.v $(ROOT)/tb_fsm_3seg_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
