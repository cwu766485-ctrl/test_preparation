# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := gray_ptr_sync
TEST_TARGETS := test_gray_ptr_sync

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_gray_ptr_sync:
	@mkdir -p $(BUILD)/gray_ptr_sync
	cd $(BUILD)/gray_ptr_sync && $(VCS) $(VCS_FLAGS) -top tb_gray_ptr_sync_smoke $(ROOT)/gray_pointer.v $(ROOT)/tb_gray_ptr_sync_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
