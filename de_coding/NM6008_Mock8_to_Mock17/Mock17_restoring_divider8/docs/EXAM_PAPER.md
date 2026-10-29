# NM6008 Practical Mock Test 17 — Restoring Divider8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design an unsigned 8-bit sequential restoring divider with a single 9-bit subtractor/comparator datapath. start accepted only when idle, captures dividend/divisor, computes one quotient bit per cycle (MSB first). Exactly eight subsequent rising edges complete the result; done is a one-clock pulse and busy clears on the eighth. Outputs quotient and remainder are held until next start/reset. Start while busy and changes to operand inputs are ignored. Divisor=0 is handled immediately on the start edge: quotient=255, remainder=dividend, div_by_zero=1, busy=0, done=1. On valid division div_by_zero=0. Async active-low reset aborts a run. Test 255/1, 255/255, 0/nonzero, and 255/0.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

single datapath restoring division, exact 8 cycles, divide by zero, live operand disturbance, done.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
