# T4 · SAIF power analysis

This stage converts the T3 `inter.vpd` switching activity to VCD/SAIF, reads
the matching synthesized netlist in `dc_shell-xg-t`, maps SAIF activity onto
`<TB_MODULE>/<DUT_INSTANCE>`, and writes `rpt_saif.txt` plus cell/hierarchical
power reports. The PDK and matching VCS/DC library setup are required.

Run in the course C shell:

```csh
csh run
```

Record Total Power and units from `rpt_power.txt`; inspect `rpt_saif.txt` for
unmatched activity. If `inter.vpd` is absent, first rerun T3 with VPD capture
enabled. For GUI/manual alternatives see the
[report guide](../../../../tools/EXAM_REPORT_GUIDE.md).
