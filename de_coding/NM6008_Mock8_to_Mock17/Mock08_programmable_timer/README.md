# NM6008 Mock 8: Programmable Timer

Top RTL: `programmable_timer`; TB: `tb_programmable_timer`; reset: async active-low; 10 ns clock.

Read `docs/EXAM_PAPER.md` first. **For strict mock training, don't open RTL before writing your own.**

## RTL simulation (VCS)

Run in this directory after sourcing the local Module3 VCS environment:

```bash
vcs -full64 -sverilog -debug_access+all -top tb_programmable_timer \
 tb/tb_programmable_timer.sv rtl/programmable_timer.v -o simv -l compile.log
./simv -l sim.log
grep -E 'PASS ALL|FAIL|TIMEOUT|Error' sim.log
```

## GF22 synthesis (Synopsys Design Vision/Design Compiler)

Only after pointing `.synopsys_dc.setup`, technology libraries and search paths to your **authorized lab** setup:

```bash
mkdir -p synth/netlist synth/logs
cd synth
# Start design_vision with school's env, then File > Execute Script:
# ../scripts/run_topdown.tcl
# OR from a correctly initialized synthesis shell:
# dc_shell-xg-t -f ../scripts/run_topdown.tcl
```

Outputs on a successful run: `synth/netlist/Syn_programmable_timer.v`, `.sdf`, `.sdc`, and `synth/logs/*.rpt`.
The SDC exists only if `write_sdc` succeeds. Never invent area/slack/power values.

## SDF gate-level functional regression

In local gate directory with a REAL library.f listing the mapped GF22 standard-cell *Verilog* models:

```bash
mkdir -p gate_run
cp synth/netlist/Syn_programmable_timer.v synth/netlist/Syn_programmable_timer.sdf gate_run/
cp tb/tb_programmable_timer.sv tb/tb_programmable_timer_gate.sv gate_run/
# Place a working library.f into gate_run, using your lab's licensed libraries.
cd gate_run
vcs -full64 -sverilog -debug_access+all +neg_tchk +incdir+. \
 -top tb_programmable_timer tb_programmable_timer_gate.sv Syn_programmable_timer.v \
 -f library.f -o simv_gate -l gate_compile.log
./simv_gate -l gate_sim.log
grep -inE 'SDF|annotation|FAIL|PASS ALL|Error|Warning' gate_sim.log
ls -lh inter.vpd
```

`tb_programmable_timer_gate.sv` defines GATE_SDF/VCS_VPD, includes the SAME self-checking TB, annotates
SDF onto instance `dut`, and captures `inter.vpd`. If self-checks fail because SDF cell delay exceeds
the TB's `#1` settling window, inspect the **real timing** and adapt sampling only with documentation;
never hide a true setup/hold violation.

## Power

```bash
# In gate_run, in VCS environment:
vpd2vcd inter.vpd inter.vcd
vcd2saif -i inter.vcd -o inter.saif
# In authorized GF22 DC environment, read mapped netlist & link first:
# read_verilog synth/netlist/Syn_programmable_timer.v
# current_design programmable_timer
# link
# read_saif -input gate_run/inter.saif -instance tb_programmable_timer/dut
# report_saif -hierarchy
# report_power
```

Check SAIF hierarchy and percentage of annotated DUT instances. No local proprietary
`.db`/`.lib`/licenses should be committed or included in this ZIP.
