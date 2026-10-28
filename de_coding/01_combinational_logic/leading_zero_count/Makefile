TOP      := tb_lzc32
RTL      := lzc32.v
TB       := tb.sv

SIMV     := simv
FSDB     := lzc32.fsdb

VCS      := vcs
VERDI    := verdi

VCS_OPTS := -full64 \
            -sverilog \
            -debug_access+all \
            -kdb \
            -top $(TOP)

.PHONY: all compile run verdi clean

all: run

compile:
	$(VCS) $(VCS_OPTS) \
		$(RTL) $(TB) \
		-o $(SIMV)

run: compile
	./$(SIMV)

verdi:
	$(VERDI) -sv \
		$(RTL) $(TB) \
		-ssf $(FSDB) &

clean:
	rm -rf $(SIMV) \
	       $(SIMV).daidir \
	       csrc \
	       ucli.key \
	       *.fsdb \
	       novas.conf \
	       verdiLog \
	       *.log

# Generated VCS smoke targets (run: make test or make test_<module>).
ROOT := $(abspath .)
BUILD := build
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
TOPS := lzc32
TEST_TARGETS := test_lzc32

.PHONY: all test clean $(TEST_TARGETS)
test: $(TEST_TARGETS)

test_lzc32:
	@mkdir -p $(BUILD)/lzc32
	cd $(BUILD)/lzc32 && $(VCS) $(VCS_FLAGS) -top tb_lzc32_smoke $(ROOT)/lzc32.v $(ROOT)/tb_lzc32_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log


.PHONY: clean_generated_build
clean: clean_generated_build
clean_generated_build:
	rm -rf build
