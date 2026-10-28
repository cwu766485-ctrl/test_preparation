# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := event_counter_cdc pulse_handshake pulse_sync
TEST_TARGETS := test_event_counter_cdc test_pulse_handshake test_pulse_sync

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_event_counter_cdc:
	@mkdir -p $(BUILD)/event_counter_cdc
	cd $(BUILD)/event_counter_cdc && $(VCS) $(VCS_FLAGS) -top tb_event_counter_cdc_smoke $(ROOT)/event_counter_cdc.v $(ROOT)/tb_event_counter_cdc_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_pulse_handshake:
	@mkdir -p $(BUILD)/pulse_handshake
	cd $(BUILD)/pulse_handshake && $(VCS) $(VCS_FLAGS) -top tb_pulse_handshake_smoke $(ROOT)/../multi_bit_synchronizer/multi_bit_synchronizer.v $(ROOT)/pulse_handshake.v $(ROOT)/tb_pulse_handshake_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_pulse_sync:
	@mkdir -p $(BUILD)/pulse_sync
	cd $(BUILD)/pulse_sync && $(VCS) $(VCS_FLAGS) -top tb_pulse_sync_smoke $(ROOT)/pulse_sync.v $(ROOT)/tb_pulse_sync_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
