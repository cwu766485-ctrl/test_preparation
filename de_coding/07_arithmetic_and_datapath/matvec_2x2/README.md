# Matvec 2X2

RTL: `matvec_2x2.v`  
Testbench: `tb_matvec_2x2.v`  
Top module: `matvec_2x2`

## Exam commands (Linux / Rocky Linux)

From this directory, compile and run with VCS:

```sh
make
```

A successful self-check prints `PASS:`. Remove compiler and simulator outputs with:

```sh
make clean
```

If the Synopsys environment is not initialized in the exam lab, source the lab-provided setup script before running `make`.

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `matvec 2x2`，RTL 顶层/子模块为 `matvec_2x2`。 源文件说明：Signed 2x2 matrix times 2x1 vector, scheduled as four multiply-accumulate steps. Inputs are captured at START; DONE pulses after the fourth step.

**RTL 文件：**`matvec_2x2.v`。

**TB 文件：**
- `tb_matvec_2x2.v`（顶层 `tb_matvec_2x2`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
