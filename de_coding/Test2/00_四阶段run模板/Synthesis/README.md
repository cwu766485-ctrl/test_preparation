# T2 · Design Vision synthesis

Put only synthesizable RTL in `sources/`; the `Synthesis/run` script copies the
files named by the root `exam_config.csh` and writes `scripts/ReadVerilogFiles.tcl`.
Before running, rename the top Tcl to `scripts/<TOP>.tcl`, make
`scripts/run_topdown.tcl` source it, check the top name and `MyDefaults.con`
constraints, and preserve the course GF22 setup/library files.

Run inside the course C shell:

```csh
csh run
```

Inspect `logs/run_exam_syn.log`, `logs/report.rpt`, and `netlist/Syn_<TOP>.v`,
`.sdf`, and `.sdc` if emitted. Confirm mapped library cells, area, timing/slack,
and power report; open the mapped top in Design Vision Schematic View and save
a screenshot. If the batch Tcl is incompatible with the installed release, run
the same `scripts/run_topdown.tcl` from Design Vision GUI as described in the
[report guide](../../../tools/EXAM_REPORT_GUIDE.md).
