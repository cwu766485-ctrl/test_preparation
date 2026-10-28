# ============================================================
# Day8 - Q4/Q5/Q6
# Comparator / Parity / Binary-Gray
# ============================================================

VCS   := vcs
VERDI := verdi

TOP := tb_q4_q5_q6

SRC := \
	comparator.v \
	parity_gen.v \
	bin_gray.v \
	tb.sv

SIMV := simv

VCS_FLAGS := \
	-full64 \
	-sverilog \
	-debug_access+all \
	-kdb \
	-timescale=1ns/1ps

.PHONY: all comp run verdi clean

all: run

# ------------------------------------------------------------
# Compile
# ------------------------------------------------------------
comp:
	$(VCS) $(VCS_FLAGS) \
		$(SRC) \
		-top $(TOP) \
		-o $(SIMV) \
		-l compile.log

# ------------------------------------------------------------
# Simulation
# ------------------------------------------------------------
run: comp
	./$(SIMV) -l sim.log

# ------------------------------------------------------------
# Open waveform
# ------------------------------------------------------------
verdi:
	$(VERDI) -ssf q4_q5_q6.vcd &

# ------------------------------------------------------------
# Clean
# ------------------------------------------------------------
clean:
	rm -rf \
		$(SIMV) \
		simv.daidir \
		csrc \
		ucli.key \
		*.log \
		*.vcd \
		*.vpd \
		*.fsdb \
		verdiLog \
		novas.conf \
		novas.rc

# Generated VCS smoke targets (run: make test or make test_<module>).
ROOT := $(abspath .)
BUILD := build
VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps
TOPS := bin_gray comparator parity_gen
TEST_TARGETS := test_bin_gray test_comparator test_parity_gen

.PHONY: all test clean $(TEST_TARGETS)
test: $(TEST_TARGETS)

test_bin_gray:
	@mkdir -p $(BUILD)/bin_gray
	cd $(BUILD)/bin_gray && $(VCS) $(VCS_FLAGS) -top tb_bin_gray_smoke $(ROOT)/bin_gray.v $(ROOT)/tb_bin_gray_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_comparator:
	@mkdir -p $(BUILD)/comparator
	cd $(BUILD)/comparator && $(VCS) $(VCS_FLAGS) -top tb_comparator_smoke $(ROOT)/comparator.v $(ROOT)/tb_comparator_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log

test_parity_gen:
	@mkdir -p $(BUILD)/parity_gen
	cd $(BUILD)/parity_gen && $(VCS) $(VCS_FLAGS) -top tb_parity_gen_smoke $(ROOT)/parity_gen.v $(ROOT)/tb_parity_gen_smoke.v -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log


.PHONY: clean_generated_build
clean: clean_generated_build
clean_generated_build:
	rm -rf build
