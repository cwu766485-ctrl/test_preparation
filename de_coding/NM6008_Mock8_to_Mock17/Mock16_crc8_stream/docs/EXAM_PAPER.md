# NM6008 Practical Mock Test 16 — Crc8 Stream

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Build a byte-streaming CRC-8 calculator (CRC-8/SMBUS): polynomial x^8+x^2+x+1 (0x07), init=0x00, no reflection, xorout=0. When idle, start begins a new frame and clears crc; start does NOT consume data. Thereafter each byte with valid=1 is folded in MSB-first. On valid && last, update CRC with the final byte, pulse done for one clock, leave busy, and retain CRC. last with valid=0 is ignored. start while busy is ignored. Gaps must retain CRC. Asynchronous active-low reset. Validate the ASCII bytes "123456789" have CRC 0xF4.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

CRC-8 golden 0xF4, valid gaps, last-vs-valid, frame restart, byte order.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
