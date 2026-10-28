# 16_代码改错

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**故意含有多个错误版本；对应 TB 的预期是检测到错误，不应把这些 bug RTL 当作正确提交版本。

**RTL 文件：**`Bug1_ShiftReg4.v`, `Bug2_Counter4.v`, `Bug3_Adder4.v`, `Bug4_MAC.v`, `Bug5_Mux4.v`, `Bug6_SeqDet101.v`。

**TB 文件：**
- `Adder4_tb.v`（顶层 `Adder4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `Counter4_tb.v`（顶层 `Counter4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `MAC_tb.v`（顶层 `MAC_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `Mux4_tb.v`（顶层 `Mux4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `SeqDet101_tb.v`（顶层 `SeqDet101_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `ShiftReg4_tb.v`（顶层 `ShiftReg4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

该 Makefile 调用全套 Test2 回归；故意错误的 6 个变体必须被 TB 检出。仿真在临时目录运行并自动清理。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
