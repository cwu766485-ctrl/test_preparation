# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := shift_reg universal_sr
TEST_TARGETS := test_shift_reg test_universal_sr

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_shift_reg:
	@mkdir -p $(BUILD)/shift_reg
	cd $(BUILD)/shift_reg && $(VCS) $(VCS_FLAGS) -top tb_shift_reg_smoke $(ROOT)/shift_registers.v $(ROOT)/tb_shift_reg_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_universal_sr:
	@mkdir -p $(BUILD)/universal_sr
	cd $(BUILD)/universal_sr && $(VCS) $(VCS_FLAGS) -top tb_universal_sr_smoke $(ROOT)/shift_registers.v $(ROOT)/tb_universal_sr_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
