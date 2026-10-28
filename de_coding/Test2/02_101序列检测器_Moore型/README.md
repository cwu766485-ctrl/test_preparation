# 02_101序列检测器_Moore型

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `02_101序列检测器_Moore型`，RTL 顶层/子模块为 `SeqDet101`。 源文件说明：第 2 题：Moore 型有限状态机，逐拍检测串行输入 DIN 中的 101。 允许重叠，例如 10101 中第 1～3 位和第 3～5 位各检测一次。 CLK：时钟，DIN 在上升沿被采样。 NRST：低电平有效的异步复位，不必等待时钟即可回到初态。 DIN：串行数据输入，每个时钟送入一位。 DET：收到完整 101 后为 1，持续一个时钟周期…

**RTL 文件：**`SeqDet101.v`。

**TB 文件：**
- `SeqDet101_tb.v`（顶层 `SeqDet101_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
