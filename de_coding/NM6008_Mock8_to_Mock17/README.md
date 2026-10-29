# NM6008 Mock Tests 8–17 | Practical Digital IC Design

Ten **predicted practice exercises**, not leaked or official exam questions.
These are based on common RTL/data-path/FSM/verification themes from NM6008 Module 3–5,
Mock1 Secret Code, Mock2 Serial Adder, Mock3 Sequential 2x2 Matrix Multiplier,
and the user's prior coding syllabus. They are not asserted exam probabilities.

| Mock | Problem | Main traps |
|---|---|---|
| 8 | programmable_timer | load priority, zero-period clamp, pause, wrap, counter width, one-cycle tick |
| 9 | serial_comparator8 | MSB-first ordering, stalls, initial tie, finish pulse, conflicting start, signedness |
| 10 | overlap_detector | overlap 1101101, valid gaps, short streams, reset, one-cycle pulse |
| 11 | bcd_stopwatch | BCD validity, 09->10 carry, 99->00 wrap, clear priority, pause |
| 12 | sync_fifo8 | empty write/read, full simultaneous read/write, ordering, wrap-around, backpressure |
| 13 | uart_tx8 | 8N1 LSB-first, stop bit, baud divisor, held data, busy start rejection |
| 14 | pwm_generator8 | 0% duty, 100% duty, period=0, mid-stream reconfigure, pause |
| 15 | pulse_width_meter8 | 1/255/256/300 high cycles, saturation overflow, arm priority, one-clock done |
| 16 | crc8_stream | CRC-8 golden 0xF4, valid gaps, last-vs-valid, frame restart, byte order |
| 17 | restoring_divider8 | single datapath restoring division, exact 8 cycles, divide by zero, live operand disturbance, done |

## Directory organization

Each mock contains `docs/EXAM_PAPER.md`, `rtl/<top>.v`, `tb/tb_<top>.sv`,
`tb/tb_<top>_gate.sv`, `scripts/{ReadVerilogFiles,run_topdown,<top>}.tcl`,
and `README.md`. Shared `RUN_ALL_RTL.sh` compiles each test using Icarus Verilog
when installed; otherwise use the per-test VCS commands in each README.

## Exam methodology

First read only the Exam Paper; write RTL from scratch; then run the self-check TB.
Use the provided RTL only as a reference after attempting the problem.

Synthesis Tcl assumes the GF22 library setup and should be executed in each problem's
`synth/` working directory. No license, PDK, or standard-cell library models are included.

## Verification boundary

Static checks performed in the file-building environment are summarized in
`VALIDATION_REPORT.md`. **Real VCS/GF22 synthesis/SDF/SAIF signoff requires the NTU lab.**
