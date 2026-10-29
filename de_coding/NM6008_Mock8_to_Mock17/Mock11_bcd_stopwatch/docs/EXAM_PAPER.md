# NM6008 Practical Mock Test 11 — Bcd Stopwatch

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design a two-digit decimal stopwatch counter 00..99 using BCD tens/ones outputs. Asynchronous active-low reset clears digits and wrap. On each clock clear has priority and resets to 00; otherwise increment only if enable and tick_in are both 1. From 99 go to 00 and pulse wrap for one cycle. When paused, or tick_in=0, hold digits and clear wrap. No invalid BCD digits should occur. Demonstrate 00→09→10 and 99→00; analyze critical path.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

BCD validity, 09->10 carry, 99->00 wrap, clear priority, pause.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
