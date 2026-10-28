# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := pwm
TEST_TARGETS := test_pwm

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_pwm:
	@mkdir -p $(BUILD)/pwm
	cd $(BUILD)/pwm && $(VCS) $(VCS_FLAGS) -top tb_pwm_smoke $(ROOT)/pwm.v $(ROOT)/tb_pwm_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
