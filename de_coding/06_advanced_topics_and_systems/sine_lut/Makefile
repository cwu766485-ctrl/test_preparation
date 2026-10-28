# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := sin_lut
TEST_TARGETS := test_sin_lut

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_sin_lut:
	@mkdir -p $(BUILD)/sin_lut
	cd $(BUILD)/sin_lut && $(VCS) $(VCS_FLAGS) -top tb_sin_lut_smoke $(ROOT)/sine_lut.v $(ROOT)/tb_sin_lut_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
