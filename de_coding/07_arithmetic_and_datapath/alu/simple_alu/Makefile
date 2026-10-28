# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := simple_alu
TEST_TARGETS := test_simple_alu

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_simple_alu:
	@mkdir -p $(BUILD)/simple_alu
	cd $(BUILD)/simple_alu && $(VCS) $(VCS_FLAGS) -top tb_simple_alu_smoke $(ROOT)/simple_alu.v $(ROOT)/tb_simple_alu_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
