# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := parity_gen
TEST_TARGETS := test_parity_gen

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_parity_gen:
	@mkdir -p $(BUILD)/parity_gen
	cd $(BUILD)/parity_gen && $(VCS) $(VCS_FLAGS) -top tb_parity_gen_smoke $(ROOT)/parity_gen.v $(ROOT)/tb_parity_gen_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
