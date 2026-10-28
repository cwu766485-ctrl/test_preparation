# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := credit_qos_arbiter round_robin_arbiter strict_priority_arbiter weighted_round_robin_arbiter
TEST_TARGETS := test_credit_qos_arbiter test_round_robin_arbiter test_strict_priority_arbiter test_weighted_round_robin_arbiter

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_credit_qos_arbiter:
	@mkdir -p $(BUILD)/credit_qos_arbiter
	cd $(BUILD)/credit_qos_arbiter && $(VCS) $(VCS_FLAGS) -top tb_credit_qos_arbiter_smoke $(ROOT)/credit_qos_arbiter.v $(ROOT)/tb_credit_qos_arbiter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_round_robin_arbiter:
	@mkdir -p $(BUILD)/round_robin_arbiter
	cd $(BUILD)/round_robin_arbiter && $(VCS) $(VCS_FLAGS) -top tb_round_robin_arbiter_smoke $(ROOT)/round_robin_arbiter.v $(ROOT)/tb_round_robin_arbiter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_strict_priority_arbiter:
	@mkdir -p $(BUILD)/strict_priority_arbiter
	cd $(BUILD)/strict_priority_arbiter && $(VCS) $(VCS_FLAGS) -top tb_strict_priority_arbiter_smoke $(ROOT)/strict_priority_arbiter.v $(ROOT)/tb_strict_priority_arbiter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_weighted_round_robin_arbiter:
	@mkdir -p $(BUILD)/weighted_round_robin_arbiter
	cd $(BUILD)/weighted_round_robin_arbiter && $(VCS) $(VCS_FLAGS) -top tb_weighted_round_robin_arbiter_smoke $(ROOT)/weighted_round_robin_arbiter.v $(ROOT)/tb_weighted_round_robin_arbiter_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
