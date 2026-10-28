VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps +define+VCS
TOPS := SerialSubtractor_tb
TOP ?= SerialSubtractor_tb
BUILD := build
HDL := SerialSubtractor.v SerialSubtractor_tb.v

.PHONY: all test clean
all: test

test: test_$(TOP)

test_%:
	@mkdir -p $(BUILD)/$*
	@for file in *.txt; do if test -f "$$file"; then cp "$$file" $(BUILD)/$*/; fi; done
	cd $(BUILD)/$* && $(VCS) $(VCS_FLAGS) -top $* $(addprefix ../../,$(HDL)) -o simv -l compile.log
	cd $(BUILD)/$* && ./simv -l sim.log
	@if grep -Eiq '(^|[^[:alpha:]_])FAIL([^[:alpha:]_]|$)|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)' $(BUILD)/$*/sim.log; then cat $(BUILD)/$*/sim.log; exit 1; else echo 'PASS: $*'; fi

clean:
	rm -rf $(BUILD)
