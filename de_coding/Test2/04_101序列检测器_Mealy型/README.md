# 04_101序列检测器_Mealy型

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `04_101序列检测器_Mealy型`，RTL 顶层/子模块为 `SeqDet101_Mealy`。 源文件说明：第 4 题：Mealy 型状态机，检测串行输入 DIN 中的 101，允许重叠。 当最后一位 1 出现在 DIN 上时，DET 在同一个周期即可为 1。 第 2 题的 Moore 型版本需要额外的已检测状态，输出在采样后才出现。 Mealy 输出同时由当前状态和当前输入决定。 因此可少用一个状态，且不用等待输入再被登记到结果状态…

**RTL 文件：**`SeqDet101_Mealy.v`。

**TB 文件：**
- `SeqDet101_Mealy_tb.v`（顶层 `SeqDet101_Mealy_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
