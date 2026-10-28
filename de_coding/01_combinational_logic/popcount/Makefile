# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := count_32 popcount32
TEST_TARGETS := test_count_32 test_popcount32

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_count_32:
	@mkdir -p $(BUILD)/count_32
	cd $(BUILD)/count_32 && $(VCS) $(VCS_FLAGS) -top tb_count_32_smoke $(ROOT)/count_32.v $(ROOT)/tb_count_32_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_popcount32:
	@mkdir -p $(BUILD)/popcount32
	cd $(BUILD)/popcount32 && $(VCS) $(VCS_FLAGS) -top tb_popcount32_smoke $(ROOT)/popcount32.v $(ROOT)/tb_popcount32_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
