# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := async_dp_ram
TEST_TARGETS := test_async_dp_ram

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_async_dp_ram:
	@mkdir -p $(BUILD)/async_dp_ram
	cd $(BUILD)/async_dp_ram && $(VCS) $(VCS_FLAGS) -top tb_async_dp_ram_smoke $(ROOT)/async_dual_port_ram.v $(ROOT)/tb_async_dp_ram_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
