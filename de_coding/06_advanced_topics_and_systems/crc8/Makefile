# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := crc8
TEST_TARGETS := test_crc8

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_crc8:
	@mkdir -p $(BUILD)/crc8
	cd $(BUILD)/crc8 && $(VCS) $(VCS_FLAGS) -top tb_crc8_smoke $(ROOT)/crc8.v $(ROOT)/tb_crc8_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
