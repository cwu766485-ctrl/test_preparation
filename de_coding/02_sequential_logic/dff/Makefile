# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := dff_async dff_sync_en
TEST_TARGETS := test_dff_async test_dff_sync_en

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_dff_async:
	@mkdir -p $(BUILD)/dff_async
	cd $(BUILD)/dff_async && $(VCS) $(VCS_FLAGS) -top tb_dff_async_smoke $(ROOT)/dff.v $(ROOT)/tb_dff_async_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_dff_sync_en:
	@mkdir -p $(BUILD)/dff_sync_en
	cd $(BUILD)/dff_sync_en && $(VCS) $(VCS_FLAGS) -top tb_dff_sync_en_smoke $(ROOT)/dff.v $(ROOT)/tb_dff_sync_en_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
