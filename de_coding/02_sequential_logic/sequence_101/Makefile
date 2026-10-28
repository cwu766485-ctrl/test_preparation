# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := seq_detect_101
TEST_TARGETS := test_seq_detect_101

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_seq_detect_101:
	@mkdir -p $(BUILD)/seq_detect_101
	cd $(BUILD)/seq_detect_101 && $(VCS) $(VCS_FLAGS) -top tb_seq_detect_101_smoke $(ROOT)/sequence_101.v $(ROOT)/tb_seq_detect_101_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
