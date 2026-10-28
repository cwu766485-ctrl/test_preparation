# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := pulse_width
TEST_TARGETS := test_pulse_width

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_pulse_width:
	@mkdir -p $(BUILD)/pulse_width
	cd $(BUILD)/pulse_width && $(VCS) $(VCS_FLAGS) -top tb_pulse_width_smoke $(ROOT)/pulse_width.v $(ROOT)/tb_pulse_width_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
