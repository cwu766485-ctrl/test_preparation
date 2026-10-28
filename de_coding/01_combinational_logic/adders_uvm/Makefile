VCS      ?= vcs
VERDI    ?= verdi
SIMV     := simv
TEST     ?= adder_test

VCS_OPTS := -full64 -sverilog -ntb_opts uvm-1.2 \
            -timescale=1ns/1ps \
            -debug_access+all -kdb \
            +incdir+tb

.PHONY: all compile run regress verdi clean help

all: run

compile:
	$(VCS) $(VCS_OPTS) -f filelist.f -o $(SIMV) -l compile.log

run: compile
	./$(SIMV) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_MEDIUM -l sim.log

regress: run
	@echo "==== RESULT ===="
	@grep -E "UVM_(ERROR|FATAL)|SB_REPORT" sim.log || true

verdi:
	$(VERDI) -ssf adder.vcd &

clean:
	rm -rf $(SIMV) simv.daidir csrc ucli.key \
	       *.log *.vcd *.vpd *.fsdb \
	       DVEfiles verdiLog novas.* \
	       vc_hdrs.h .inter.vpd.uvm

help:
	@echo "make compile   # compile UVM TB"
	@echo "make run       # compile + run"
	@echo "make regress   # run + print UVM errors/report"
	@echo "make verdi     # open adder.vcd in Verdi"
	@echo "make clean     # remove generated files"
