# NM6008 Practical Mock Test 13 — Uart Tx8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design an 8N1 UART TX with parameter CLKS_PER_BIT=4. A start pulse in idle captures 8-bit data_in, drives TX low for the start bit, then transmits LSB-first data bits and one high stop bit. Every symbol occupies exactly CLKS_PER_BIT rising-edge intervals. busy remains asserted throughout start, data and stop symbols. At the end of the stop bit, busy deasserts, TX idles high, and done pulses one clock. start while busy is ignored, input changes after start must be ignored. Asynchronous active-low reset forces idle high. No parity. For synthesis use CLKS_PER_BIT>=2.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

8N1 LSB-first, stop bit, baud divisor, held data, busy start rejection.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
