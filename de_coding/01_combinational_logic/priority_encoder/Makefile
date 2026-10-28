# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := prio_encoder
TEST_TARGETS := test_prio_encoder

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_prio_encoder:
	@mkdir -p $(BUILD)/prio_encoder
	cd $(BUILD)/prio_encoder && $(VCS) $(VCS_FLAGS) -top tb_prio_encoder_smoke $(ROOT)/prio_encoder.v $(ROOT)/tb_prio_encoder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)


# Existing exhaustive, user-authored priority-encoder testbench.
.PHONY: test_tb_prio_encoder
test_tb_prio_encoder:
	@mkdir -p $(BUILD)/tb_prio_encoder
	cd $(BUILD)/tb_prio_encoder && $(VCS) $(VCS_FLAGS) -top tb_prio_encoder $(ROOT)/prio_encoder.v $(ROOT)/tb_prio_encoder.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && grep -q 'TEST PASS' run.log && ! grep -q 'ERROR' run.log
