# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := data_sel sel_exp
TEST_TARGETS := test_data_sel test_sel_exp

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_data_sel:
	@mkdir -p $(BUILD)/data_sel
	cd $(BUILD)/data_sel && $(VCS) $(VCS_FLAGS) -top tb_data_sel_smoke $(ROOT)/mux_01.v $(ROOT)/tb_data_sel_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_sel_exp:
	@mkdir -p $(BUILD)/sel_exp
	cd $(BUILD)/sel_exp && $(VCS) $(VCS_FLAGS) -top tb_sel_exp_smoke $(ROOT)/mux_01.v $(ROOT)/tb_sel_exp_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
