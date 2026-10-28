# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := matrix_multiplier
TEST_TARGETS := test_matrix_multiplier

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_matrix_multiplier:
	@mkdir -p $(BUILD)/matrix_multiplier
	cd $(BUILD)/matrix_multiplier && $(VCS) $(VCS_FLAGS) -top tb_matrix_multiplier_smoke $(ROOT)/matrix_multiplier.v $(ROOT)/tb_matrix_multiplier_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
