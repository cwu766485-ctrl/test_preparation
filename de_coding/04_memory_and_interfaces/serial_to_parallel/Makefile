# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := serial_to_parallel
TEST_TARGETS := test_serial_to_parallel

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_serial_to_parallel:
	@mkdir -p $(BUILD)/serial_to_parallel
	cd $(BUILD)/serial_to_parallel && $(VCS) $(VCS_FLAGS) -top tb_serial_to_parallel_smoke $(ROOT)/serial_to_parallel.v $(ROOT)/tb_serial_to_parallel_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
