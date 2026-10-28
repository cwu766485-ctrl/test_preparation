# NM6008 Module 5 signed matrix multiplier

This example follows the manual's 2-term signed dot product:
`[A1 A0] x [B1 B0]^T = A1*B1 + A0*B0`. The single signed 8-bit `A` and `B`
buses carry one operand pair per cycle. `START` starts a continuous stream;
`OUT_STROBE` marks each valid 17-bit signed result.

## RTL and testbench

- `MatrixMultiplier.v`: asynchronous active-low reset, IDLE/FIRST/SECOND
  controller, one registered 16-bit signed product, sign extension into a
  17-bit accumulator, and one-cycle output strobe. The control phases represent
  the manual's EN1 (register product), EN2 (accumulate), and EN3 (publish).
- `MatrixMultiplier_tb.sv`: reads signed operand rows from `InputVector.txt`,
  drives the two operands in sequence, and checks positive, negative, zero,
  and full-range boundary cases. It also checks the strobe pulse and reset.
- `InputVector.txt`: each row is `A1 B1 A0 B0`, decimal signed values from
  -128 through 127.

## Exam commands

In the configured Linux/WSL VCS shell:

```sh
cd de_coding/07_arithmetic_and_datapath/nm6008_matrix_multiplier
make test
make clean
```

`make test` leaves `build/MatrixMultiplier.vcd` and logs for DVE/report
screenshots. Use `make gui` to open DVE; add `CLK`, `NRST`, `START`, `A`, `B`,
`dut.state`, `dut.product_q`, `OUT`, and `OUT_STROBE` to the wave view.

For a student-style report (waveform, RTL explanation, schematic, mapped cell
and timing reports, gate-level simulation, and the Module 6 layout deliverables),
follow [`../../tools/EXAM_REPORT_GUIDE.md`](../../tools/EXAM_REPORT_GUIDE.md).
Module 6 Innovus is PDK-dependent: use the course's GF22 IO wrapper, LEF/lib,
pad files, `.globals`, `.io`, and lab setup. Do not reuse floorplan dimensions
or pad coordinates with another process kit.

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**按 Module 5 接口把两组有符号 8 位操作数串行送入，计算 A1*B1+A0*B0，使用 17 位符号扩展并以 OUT_STROBE 标记结果。

**RTL 文件：**`MatrixMultiplier.v`。

**TB 文件：**
- `MatrixMultiplier_tb.sv`（顶层 `MatrixMultiplier_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
