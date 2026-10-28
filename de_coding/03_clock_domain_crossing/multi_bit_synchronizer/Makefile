# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := multi_bit_synchronizer
TEST_TARGETS := test_multi_bit_synchronizer

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_multi_bit_synchronizer:
	@mkdir -p $(BUILD)/multi_bit_synchronizer
	cd $(BUILD)/multi_bit_synchronizer && $(VCS) $(VCS_FLAGS) -top tb_multi_bit_synchronizer_smoke $(ROOT)/multi_bit_synchronizer.v $(ROOT)/tb_multi_bit_synchronizer_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
