# NM6008 Practical Mock Test 9 — Serial Comparator8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Design an unsigned 8-bit serial comparator accepting bits MSB-first. A start pulse when idle starts a new comparison. Each later rising edge with bit_valid=1 accepts one pair (a_bit,b_bit); cycles with bit_valid=0 do not advance. On the eighth accepted pair, busy deasserts and done pulses for one clock. Results gt,eq,lt are mutually exclusive and remain until the next start/reset. A new start while busy is ignored. Asynchronous active-low reset. Report a 10ns-clock timing path after synthesis.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

MSB-first ordering, stalls, initial tie, finish pulse, conflicting start, signedness.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
