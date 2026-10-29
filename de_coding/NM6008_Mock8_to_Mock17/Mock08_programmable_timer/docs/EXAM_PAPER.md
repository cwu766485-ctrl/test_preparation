# NM6008 Practical Mock Test 8 — Programmable Timer

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design an 8-bit programmable periodic timer. CLK cycles are counted while enable=1. On asynchronous active-low reset, active_period=4, count=0 and tick=0. On load=1 (highest synchronous priority), latch period_in, treating zero as one, reset count and suppress tick. When enabled, assert a one-cycle tick on the rising edge that completes active_period cycles and wrap count to zero. Otherwise increment count. When disabled, hold count and set tick=0. A load while disabled still updates the period. No latches or inferred clocks. Clock period for practice: 10 ns.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

load priority, zero-period clamp, pause, wrap, counter width, one-cycle tick.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
