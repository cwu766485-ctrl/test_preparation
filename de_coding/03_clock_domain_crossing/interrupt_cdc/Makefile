# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := interrupt_cdc
TEST_TARGETS := test_interrupt_cdc

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_interrupt_cdc:
	@mkdir -p $(BUILD)/interrupt_cdc
	cd $(BUILD)/interrupt_cdc && $(VCS) $(VCS_FLAGS) -top tb_interrupt_cdc_smoke $(ROOT)/interrupt_cdc.v $(ROOT)/../multi_bit_synchronizer/multi_bit_synchronizer.v $(ROOT)/../pulse_sync/pulse_handshake.v $(ROOT)/tb_interrupt_cdc_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
