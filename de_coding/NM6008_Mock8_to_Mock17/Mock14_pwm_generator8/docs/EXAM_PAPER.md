# NM6008 Practical Mock Test 14 — Pwm Generator8

**Status:** predicted practice question, NOT an official NM6008 past examination.
**Suggested time:** 90–120 minutes. **RTL language:** synthesizable Verilog.
**Clock:** 10 ns; **reset:** asynchronous active-low rst_n.
**Scope:** RTL design, self-checking simulation, mapped GF22 synthesis, annotated gate simulation and switching power. **Excluded:** Module6 physical design.

## Problem statement (English)

Create a parameterized 8-bit programmable PWM with period/duty controls. Asynchronous active-low reset: active_period=4, active_duty=2, count=0. A config pulse has priority, updates both parameters atomically and restarts the PWM phase at count=0. period_in=0 clamps to 1; duty_in greater than the new period clamps to period. Each enabled rising edge advances count modulo active_period; when disabled count holds. Output PWM is combinational (count<active_duty), including DC 0% and 100%. No gated clocks. Verify that updated duty is evaluated with the NEW period, not old period.

## Deliverables and grading (100 points)

- Design explanation, block diagram and interface contract: 15
- Correct synthesizable RTL and cycle timing: 25
- Directed, boundary and randomized self-checking testbench: 25
- Mapped area, reference-cell counts and setup timing from DC: 20
- SDF gate-level PASS, VPD→VCD→SAIF power report, and evidence: 15

## Hidden traps / exam checkpoints

0% duty, 100% duty, period=0, mid-stream reconfigure, pause.

## Evidence to save

RTL PASS log; input/output timing waveforms; synthesized schematic;
`report_area`, `report_reference`, `report_timing` with timing units;
SDF annotation log; DUT activity annotation coverage; total/internal/switching/leakage power.

## Important

Actual cell area, timing and power are not predictable from RTL alone.
Do not claim GF22 signoff until VCS/DC and SAIF successfully run in the lab.
