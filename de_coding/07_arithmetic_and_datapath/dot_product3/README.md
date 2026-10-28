# Dot Product3

RTL: `dot_product3.v`  
Testbench: `tb_dot_product3.v`  
Top module: `dot_product3`

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

**设计说明：**本题练习 `dot product3`，RTL 顶层/子模块为 `dot_product3`。 源文件说明：Signed three-term dot product. START samples term zero; the next two clock edges sample terms one and two. DONE is a one-cycle pulse.

**RTL 文件：**`dot_product3.v`。

**TB 文件：**
- `tb_dot_product3.v`（顶层 `tb_dot_product3`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
