# Secret-code number generator (NM6008 assignment)

This is the implementation for the assignment that searches a preset 4-digit secret code. The older `Behavioral/` and `rtl/` folders at the parent level contain a different keypad-lock example; use this `assignment/` folder for the number-generator question.

## 1. RTL and TB design

- `rtl/secret_code_m.v`: one independent 3-bit modulo-8 counter. It has no `secret_code` port.
- `rtl/secret_code_four.v`: cascades four M blocks as a base-8 odometer. The candidate is `{v1,v2,v3,v4}`; `v4` advances every search cycle and carry advances the higher digits. The top-level logic captures and compares the secret code, stops at a match, and opens the relay.
- `rtl/secret_code_single.v`: the alternative single 12-bit counter requested for comparison.
- `tb/tb_secret_code.sv`: checks both implementations cycle-by-cycle, restart, asynchronous reset, relay hold, rollover at `7 -> 0`, and codes `0000`, `0123`, `1145`, and `7777` (base 8). The `1145` example is `12'o1145`, not decimal 1145.

The secret is latched on `activate`. Digits are 3-bit values `0..7`; for ID digits 8 and 9, substitute 0 and 1 as the assignment states. After activation, the relay remains open until reset or a new activation.

## 2. Exam commands

In the course Linux/WSL shell, load the lab's VCS setup file if needed, then run:

```sh
cd de_coding/07_arithmetic_and_datapath/secretcode/assignment
make test
make clean
```

`make test` prints `PASS` and leaves the VCD waveform under `build/secretcode_search.vcd`. For an interactive DVE run, use `make gui`; add `candidate_four`, `busy_four`, and `relay_four` to the wave view.

## 3. Report and synthesis

Use [`tools/EXAM_REPORT_GUIDE.md`](../../../tools/EXAM_REPORT_GUIDE.md) for the Module 3 Design Vision flow. Synthesize `secret_code_four` and `secret_code_single` separately with the same GF22 setup and constraints, and save each `report.rpt`, timing report, gate-level netlist, SDF, and schematic screenshot. Compare area and critical delay in the report. The PDK is supplied by the lab; the standard-cell library and license setup are not part of this assignment folder.
