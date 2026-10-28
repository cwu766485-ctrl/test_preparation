# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := half_adder
TEST_TARGETS := test_half_adder

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_half_adder:
	@mkdir -p $(BUILD)/half_adder
	cd $(BUILD)/half_adder && $(VCS) $(VCS_FLAGS) -top tb_half_adder_smoke $(ROOT)/half_adder.v $(ROOT)/tb_half_adder_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
