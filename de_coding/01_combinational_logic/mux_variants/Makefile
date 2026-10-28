# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := mux2_assign mux2_gate mux2_gate
TEST_TARGETS := test_mux2_assign test_mux2_gate test_mux2_gate

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_mux2_assign:
	@mkdir -p $(BUILD)/mux2_assign
	cd $(BUILD)/mux2_assign && $(VCS) $(VCS_FLAGS) -top tb_mux2_assign_smoke $(ROOT)/mux.v $(ROOT)/tb_mux2_assign_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_mux2_gate:
	@mkdir -p $(BUILD)/mux2_gate
	cd $(BUILD)/mux2_gate && $(VCS) $(VCS_FLAGS) -top tb_mux2_gate_smoke $(ROOT)/mux_bool.v $(ROOT)/tb_mux2_gate_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_mux2_gate:
	@mkdir -p $(BUILD)/mux2_gate
	cd $(BUILD)/mux2_gate && $(VCS) $(VCS_FLAGS) -top tb_mux2_gate_smoke $(ROOT)/mux_case.v $(ROOT)/tb_mux2_gate_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
