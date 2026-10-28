# NM6008 Mock Test 3 — Sequential 2x2 Matrix Multiplier

This is a **practice implementation** of the supplied screenshots; GF22/VCS signoff is still pending.

## Interface
Top module: `matrix_mul_2x2`; input `clk,rst_n,start,A_flat[31:0],B_flat[31:0]`; output `C00,C01,C10,C11[16:0],busy,done`. Inputs are row-major: `A_flat={a00,a01,a10,a11}`; `B_flat={b00,b01,b10,b11}`. All matrix elements are unsigned 8 bit.

## Implementation
One `8x8` multiplication operator, one shared 17-bit accumulation adder, input registers, 8-step counter and four result registers. `busy` is the RUN/IDLE FSM state. Start edge=0 captures operands and asserts busy, edges1..8 perform one product each, edge8 asserts done for one cycle and deasserts busy; edge9 deasserts done. New starts while busy and live input changes are ignored; asynchronous `rst_n` aborts and clears all outputs.

Cycle schedule:
- 1: C00 += a00*b00
- 2: C00 += a01*b10
- 3: C01 += a00*b01
- 4: C01 += a01*b11
- 5: C10 += a10*b00
- 6: C10 += a11*b10
- 7: C11 += a10*b01
- 8: C11 += a11*b11 (busy=0,done=1)

Max result: `2*255*255=130050` (17 bits). Normal case: `A=[1,2;3,4]`, `B=[5,6;7,8]`, `C=[19,22;43,50]`.

## Files
- `rtl/matrix_mul_2x2.v`: synthesizable Verilog.
- `tb/tb_matrix_mul_2x2.sv`: SV self-checking TB, 8 directed classes, 120 deterministic pseudo-random matrix tests; incremental output scoreboard.
- `tb/tb_matrix_mul_2x2_gate.sv`: gate sim, optional `+define+GATE_SDF`, `+define+VCS_VPD`.
- `scripts/`: GF22 Design Compiler synthesis Tcl templates.
- `docs/MODULE3_MODULE6_FULL_FLOW.txt`: Linux/EDA/GUI steps.
- `docs/TESTPLAN.md`: pass criteria and evidence checklist.

## RTL simulation (lab VCS environment needed)
Run from this exercise root:

```bash
vcs -full64 -sverilog -debug_access+all -top tb_matrix_mul_2x2 \
 tb/tb_matrix_mul_2x2.sv rtl/matrix_mul_2x2.v -o simv -l vcs_compile.log
./simv -l rtl_sim.log
grep 'PASS ALL' rtl_sim.log
./simv -gui
```

## Proof status
Independently checked algorithm mapping against Python on 10,000 matrices; correct reference values and width. **No actual VCS, Synopsys DC/GF22, SDF timing, SAIF power or Innovus run has been performed here**. Do not present simulated PASS statements as measured results. A 10ns clock is required by the mock; Module6 P&R is expressly out of scope. Do not publicly commit proprietary PDK, licensed libraries, .db, license files or personal IDs.
