# NM6008 exam report: run, synthesize, and document

This guide separates the course-manual requirements from the local practice
RTL. Start with the exact exam statement: module names, port widths, reset
polarity, latency, and signedness in the question always control the final
design. Use the matching folder README for its interface and expected TB result.

The sample `n-bit Serial Adder` report is a useful submission outline: waveform,
design report/cell usage, schematic, short architecture explanation, RTL, and
testbench. It records that the student did not complete waveform simulation;
the steps below produce a waveform so that section can be completed. Module 3
is the main reference for synthesis and gate simulation. Module 6 is a separate
physical-design flow for the matrix multiplier and requires the course PDK.

## A. Behavioral VCS simulation and waveform (Module 3)

In the course Linux machine or configured WSL shell, load the lab VCS setup if
the shell does not already provide VCS and a license. From a topic folder with
a plain `Makefile`:

```sh
make test
```

To run manually, use the exact TB and RTL file names from that folder's README:

```sh
vcs -full64 -sverilog -debug_access+all -timescale=1ns/1ps \
  -top <testbench_module> <rtl_file_1.v> <rtl_file_2.v> <testbench.sv> \
  -o simv
./simv
./simv -gui
```

For `.v` benches without SystemVerilog constructs, the course examples also use
`vcs -debug +v2k ...`. In DVE, expand the testbench and DUT, add clock/reset,
inputs, state/counter, data registers, and outputs to the wave view, then run
and zoom to full. Save a screenshot with the important transitions visible.
Most self-checking benches also write a `.vcd`; keep it with the report if the
submission asks for a waveform file. The DVE GUI is optional if the VCD can be
opened with an available viewer.

Capture from the waveform: reset behavior, one normal transaction, boundary
case, valid/done/strobe timing, and any restart/handshake case relevant to the
problem. Confirm the TB prints its PASS summary and has no failing checks before
using the waveform as evidence.

## B. Design Vision synthesis and report (Module 3)

1. Make a separate synthesis work copy from the course Module 3 template. Put
   synthesizable RTL in `sources/`; do not put the testbench in the synthesis
   file list. Keep the course GF22 library, setup, and constraints available.
2. Update `scripts/ReadVerilogFiles.tcl` with one `read_verilog` per RTL file.
   Update the top-specific Tcl and `scripts/run_topdown.tcl` so the selected top
   matches the actual Verilog module name. Check `current_design`, link, compile,
   and the output file names before starting.
3. Set `CLK_PERIOD` and input/output delay constraints from the question and
   clock period used by the TB. Sequential designs need a real clock constraint;
   combinational blocks need sensible input/output delays or virtual-clock
   constraints. Do not copy a serial-adder clock period into a different design.
4. In the configured course shell, start the GUI and execute the template script:

   ```csh
   source <course_synopsys_setup>
   design_vision &
   ```

   In Design Vision choose **File → Execute Script** and run
   `scripts/run_topdown.tcl`. Follow the Module 3 template's run script; it
   normally sources the setup, read-files, design-specific, and report scripts.
5. Inspect the log for read/link/compile errors. Save `logs/report.rpt` and the
   generated gate netlist, SDF, and SDC where the template emits them. In the
   Design Vision command prompt, collect the reports supported by the installed
   tool/template, for example:

   ```tcl
   report_area
   report_cell
   report_timing -significant_digits 4
   report_constraint -all_violators
   report_qor
   report_power
   ```

   Record cell counts/area, critical path and slack, and estimated power with
   units. Ensure the mapped cells are GF22 library cells; `GTECH` or generic
   unmapped cells are not a mapped technology report. Power is an estimate until
   switching activity is supplied.
6. In **Logical Hierarchy**, right-click the synthesized top and select
   **Schematic View**. Expand enough hierarchy to show the architecture and
   save a readable screenshot. In the report, explain the state machine,
   datapath, control enables, arithmetic width/signed extension, and latency.

The exact Tcl commands and output paths vary with the course template. Keep the
course-provided `.synopsys_dc.setup`, `common_setup_gf22.tcl`, `MyDefaults.con`,
library file list, and report script together; do not assume their GF22 paths
exist in a different lab installation.

## C. Post-synthesis gate simulation (Module 3)

Use a netlist, SDF, standard-cell Verilog models, and library file list generated
for the same synthesis run. The TB's `$sdf_annotate` instance path must match
the synthesized DUT instance. From the gate-simulation directory:

```csh
vcs -full64 -debug +v2k +neg_tchk +define+GATE_SIM \
  <testbench.v> <Syn_top.v> -f library.f -o simv
./simv
```

The course TB may also need `+define+VCS` for VPD capture. Check the log for
successful SDF annotation and compare outputs against the behavioral run. A
missing/mismatched SDF, library, instance path, or technology setup means the
gate-delay result is not validated; do not report that run as successful.

## D. Module 6 Innovus layout (matrix-multiplier assignment only)

The Module 6 exercise is not a generic command sequence that can be run on any
RTL folder. It needs the course GF22 PDK, pad libraries, technology LEFs/libs,
IO wrapper/netlist, pin placement file, `.globals`, `.io`, SDC, and Innovus setup.
Use the handout's matching Module 6 project as a template and replace its design
files only after checking that all pad and port names still match.

From the course machine, use its prescribed C shell and setup:

```csh
cd ~/Module6
source cshrc_inno
innovus
```

Then follow the supplied `scripts/script.tcl` and the Module 6 sequence in order:

1. `source Syn_MatrixMultiplier_IO.globals`, then `init_design`.
2. Clear/connect global power and ground nets to the correct library pins.
3. Create the floorplan using the course site, core dimensions, and margins.
4. Add power rings/stripes and power-route connections; place required IO
   fillers, endcaps, and standard cells.
5. Run pre-CTS timing, optimization and placement checks; build the clock tree
   (CTS), then run post-CTS checks.
6. Route signal nets, run post-route timing/DRC checks, and generate the course
   deliverables: routed netlist, SDF, SPEF, and GDS stream-out.

The Module 6 handout's command landmarks are below. Compare them against the
course `script.tcl`; the supplied script is authoritative for the installed
project and may include extra IO/filler/technology setup:

```tcl
source Syn_MatrixMultiplier_IO.globals
init_design
clearGlobalNets
globalNetConnect vdd -type pgpin -pin VDD -inst *
globalNetConnect gnd -type pgpin -pin VSS -inst *

# Only the handout's example floorplan; use only with its GF22 site/project.
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site GF22_SST -d 1400 1400 150 150 150 150 -noSnapToGrid

# Course script also supplies its exact addRing, sroute, filler and endcap setup.
setPlaceMode -fp false
placeDesign
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports \
  -numPaths 50 -prefix Syn_MatrixMultiplier_IO_preCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS
create_ccopt_clock_tree_spec
ccopt_design -prefix cts
source ./scripts/Route.tcl

# Post-route extraction and the files the handout asks students to produce.
timeDesign -signoff -pathReports -drvReports -slackReports -numPaths 50 \
  -prefix Syn_MatrixMultiplier_IO_postRoute -outDir timingReports
rcOut -spef Syn_MatrixMultiplier_IO.spef -rc_corner typical
all_hold_analysis_views
all_setup_analysis_views
write_sdf Syn_MatrixMultiplier_IO.sdf
saveNetlist output_netlist/Syn_MatrixMultiplier_IO.v
streamOut Syn_MatrixMultiplier_IO.gds2 -mapFile <foundry_gds_layermap> \
  -libName DesignLib -structureName Syn_MatrixMultiplier_IO -units 1000 -mode ALL
```

The handout additionally runs detailed `addRing`, `sroute`, filler/endcap, and
post-route extraction commands. Keep its exact layer names (`C1/C2`, `MET1`…)
and cell prefixes only with the matching library. If any input file is missing,
stop and request/locate the correct course project files rather than guessing
PDK names. Save `timingReports/*preCTS.summary`, `*postCTS.summary`,
`*postRoute.summary`, and the hold reports along with the floorplan/CTS/route
screenshots.

Save screenshots of the floorplan, placed design, clock tree, routed design,
and the relevant timing/DRC reports. Use the exact Tcl commands, site name,
power-net names, and dimensions supplied by the local GF22 project. Do not
invent or reuse floorplan sizes, pin coordinates, or power-pin names for another
PDK. If the machine does not have the course PDK/Innovus/license, document the
missing prerequisite; the flow cannot be honestly claimed as run.

## E. One-page report checklist

- [ ] Problem statement, assumptions, port table, reset and latency.
- [ ] RTL architecture explanation and annotated schematic screenshot.
- [ ] Self-checking TB summary and representative behavioral waveform.
- [ ] Synthesis cell/area, critical timing/slack, and power estimate with units.
- [ ] Mapped netlist and SDF gate simulation result, if required and available.
- [ ] Module 6 floorplan/placement/CTS/route screenshots and reports for the
      matrix assignment, if the course environment provides its PDK.
- [ ] Final RTL and TB source files in the appendix or submission folder.
- [ ] Run `make clean` in the practice folder after collecting the required
      outputs; first copy screenshots/reports that must be submitted.

No formal verification is assumed by this practice flow. Simulation coverage
only supports the cases actually exercised by the testbench.
