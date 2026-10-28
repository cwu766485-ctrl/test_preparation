# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := bit_sync2
TEST_TARGETS := test_bit_sync2

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_bit_sync2:
	@mkdir -p $(BUILD)/bit_sync2
	cd $(BUILD)/bit_sync2 && $(VCS) $(VCS_FLAGS) -top tb_bit_sync2_smoke $(ROOT)/bit_synchronizer.v $(ROOT)/tb_bit_sync2_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
