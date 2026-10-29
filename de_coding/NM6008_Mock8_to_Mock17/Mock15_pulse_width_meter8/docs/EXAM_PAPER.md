# NM6008 Practical Mock Test 15 — Pulse Width Meter8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Implement an 8-bit pulse-width meter. On an active-low async reset, clear all outputs. When idle, arm=1 AND signal_in=1 on a rising edge starts a measurement, counting that first sampled high cycle as width=1. While busy, count each additional high sample (saturating at 255); overflow is set if at least 256 sampled high cycles occur. The first subsequent low sample ends measurement: assert done for one clock, latch width (max 255), deassert busy and preserve overflow. Ignore arm when busy. A new measurement clears previous overflow, width and done. Glitches shorter than a clock may be missed by design. Give timing and overflow behavior.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

1/255/256/300 high cycles, saturation overflow, arm priority, one-clock done.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
