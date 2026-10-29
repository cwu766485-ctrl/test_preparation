# NM6008 Practical Mock Test 12 — Sync Fifo8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Implement a synchronous 8-entry x 8-bit FIFO with push/pop on one clock, asynchronous active-low reset, occupancy count 0..8, full and empty flags, combinational head data rdata. A push is accepted if w_en && w_ready. A pop is accepted if r_en && r_valid. When full and read+write occur together, BOTH operations are accepted and the old head is returned; occupancy stays 8. When empty and read+write coincide, ONLY the write is accepted (no bypass), occupancy becomes 1. w_ready may depend on r_en only when full; r_valid is asserted only when nonempty. Output rdata is zero when empty. Reset flushes queue. Do not infer latches. Note RAM implementation and read-during-write behavior are technology dependent.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

empty write/read, full simultaneous read/write, ordering, wrap-around, backpressure.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
