# Generated per-directory VCS targets; run make or make test_<module>.
VCS ?= vcs
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
ROOT := $(abspath .)
BUILD := build
TOPS := uart_rx
TEST_TARGETS := test_uart_rx

.PHONY: all test clean $(TEST_TARGETS)
all: test
test: $(TEST_TARGETS)

test_uart_rx:
	@mkdir -p $(BUILD)/uart_rx
	cd $(BUILD)/uart_rx && $(VCS) $(VCS_FLAGS) -top tb_uart_rx_smoke $(ROOT)/uart_rx.v $(ROOT)/tb_uart_rx_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

clean:
	rm -rf $(BUILD)
