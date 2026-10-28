# NM6008 Mock Test 3 test plan

## Part 1: RTL (35)
- Four 8-bit unsigned A and B elements, row-major.
- Exactly one RTL `*` multiplier and one shared accumulation `+` adder.
- Four 17-bit output accumulators.
- RUN/IDLE FSM and 8 calculation cycles after start edge.
- Busy start ignored, inputs latched, active-low asynchronous reset.
- One-cycle done pulse, stable completed results until next start/reset.

## Part 2: Functional verification (25)
TC01 normal: A=[1,2;3,4], B=[5,6;7,8] => C=[19,22;43,50].
TC02 zero matrix. TC03 identity. TC04 all-255 maximum => 130050.
TC05 change external A_flat/B_flat while busy. TC06 assert start during busy.
TC07 async reset after three calculation edges then recovery.
TC08 busy high for cycles 0..7, down at cycle8; done only cycle8.
120 deterministic pseudo-random input pairs and independent scoreboard;
compare ALL four partial sums after each compute edge, not only at done.
The checked boxes require actual VCS logs; file existence alone is not a pass.

## Part 3: synthesis (20)
Run DC with authorized GF22 tech/setup and 10 ns clock. Collect mapped
Schematic, check_design, reports: area, references/seq cell count, worst
setup path, slack, clock period. Verify unresolved references are zero.
Time units and IO uncertainty/input delay/output delay must be stated.

## Part 4: power (15)
Generate VPD/VCD and SAIF. Read SAIF into *same* mapped netlist and
correct TB instance. Confirm activity annotation. Record real internal,
switching, leakage, total power (units included). Isolate time windows
before comparing idle vs active.

## Part 5: report (5)
Brief PDF: architecture + FSM schedule + testcases/waveform + mapped
schematic + area/timing/power and explicit assumptions/warnings.

## Additional (NOT assessed in screenshot)
Module6 Innovus P&R and DRC/LVS are excluded by this mock. See
MODULE3_MODULE6_FULL_FLOW.txt for optional directions.

## Signoff gates
(1) Source authored, (2) available algorithm checks, (3) real RTL VCS,
(4) GF22 synthesis, (5) gate-level SDF + power. None of (3-5) should be
claimed without actual lab logs.
