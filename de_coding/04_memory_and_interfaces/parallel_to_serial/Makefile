# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := parallel_to_serial
TEST_TARGETS := test_parallel_to_serial

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_parallel_to_serial:
	@mkdir -p $(BUILD)/parallel_to_serial
	cd $(BUILD)/parallel_to_serial && $(VCS) $(VCS_FLAGS) -top tb_parallel_to_serial_smoke $(ROOT)/parallel_to_serial.v $(ROOT)/tb_parallel_to_serial_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
