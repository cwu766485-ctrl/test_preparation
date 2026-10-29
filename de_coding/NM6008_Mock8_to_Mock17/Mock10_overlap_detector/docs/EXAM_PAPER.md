# NM6008 Practical Mock Test 10 — Overlap Detector

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design an overlapping detector for bit pattern 1101. On each rising edge with bit_valid=1, append din to the stream. Assert match for one cycle when the latest four accepted bits are 1101, including overlapping matches. bit_valid=0 must not change stream history and must clear match. Asynchronous active-low reset. Test gap cycles, repeated matches, and reset midway. A single-cycle match can be Mealy-style registered output; no need to implement a textbook explicit FSM if an equivalent shift-register design is correct.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

overlap 1101101, valid gaps, short streams, reset, one-cycle pulse.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
