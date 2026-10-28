# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := sync_fifo
TEST_TARGETS := test_sync_fifo

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_sync_fifo:
	@mkdir -p $(BUILD)/sync_fifo
	cd $(BUILD)/sync_fifo && $(VCS) $(VCS_FLAGS) -top tb_sync_fifo_smoke $(ROOT)/sync_fifo.v $(ROOT)/tb_sync_fifo_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
