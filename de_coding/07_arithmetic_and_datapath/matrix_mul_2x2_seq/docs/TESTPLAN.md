# NM6008 Mock3 test plan / scoring (100 points)

## Part 1: RTL (35)
- Unsigned row-major A/B elements, one 8×8 multiply and one 17-bit accumulate operator, four 17-bit outputs.
- RUN/IDLE control, operands captured at start, exactly eight computation cycles.
- `busy` start ignored, async active-low reset, `done` pulse one cycle.

## Part 2: Functional verification (25)
- Normal A=[1,2;3,4], B=[5,6;7,8] => C=[19,22;43,50].
- Zero, identity, all-255 maximum (130050), operand changes while busy, extra start while busy, async reset/restart, cycle-accurate busy/done, 120 pseudo-random matrices.
- Scoreboard checks all four partial results at each compute edge; simulator PASS must be observed.

## Part 3: Synthesis (20)
- Authorized GF22 setup, 10 ns clock, mapped schematic, no unresolved references.
- Report cell area, cell/reference counts, worst path timing, slack, units, setup assumptions.

## Part 4: Power (15)
- Gate VPD → VCD → SAIF, correct DUT hierarchy/coverage, real report_power values (internal/switching/leakage/total).

## Part 5: Report (5)
- Architecture/resource sharing, FSM schedule, timing diagram/waveforms, screenshot evidence and truthful assumptions.

Module 6 P&R is out of scope for this mock. Presence of RTL/TB files alone is not proof of VCS/STA/GF22 sign-off.
