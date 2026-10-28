# T3 · Gate-level VCS simulation

This folder runs the synthesized netlist with the matching standard-cell model
list and SDF. Do not mix files from different synthesis runs. The script copies
`Syn_<TOP>.v/.sdf`, the behavioral testbench, optional vector file, and SDC into
this folder; `library.f` must name the correct course models.

Run in the course C shell:

```csh
csh run
```

Review `compile_gate.log` and `sim_gate.log` for successful SDF annotation and
the same functional checks as T1. Confirm the new `inter.vpd` exists before T4.
Use the TB's actual DUT instance in `$sdf_annotate` and in the root
`exam_config.csh`.
