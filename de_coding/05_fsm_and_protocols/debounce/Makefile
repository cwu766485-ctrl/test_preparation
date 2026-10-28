# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := debounce
TEST_TARGETS := test_debounce

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_debounce:
	@mkdir -p $(BUILD)/debounce
	cd $(BUILD)/debounce && $(VCS) $(VCS_FLAGS) -top tb_debounce_smoke $(ROOT)/debounce.v $(ROOT)/tb_debounce_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
