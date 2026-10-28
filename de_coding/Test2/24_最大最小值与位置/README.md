# 24_最大最小值与位置

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `24_最大最小值与位置`，RTL 顶层/子模块为 `MaxMin`。 源文件说明：第24题：连续 N=8 拍输入无符号 8 位 DIN；START 与首个数同拍，仅空闲时有效。 输出最大值 MAX、最小值 MIN，以及最大值第一次出现的位置 IMAX（从 0 开始）。 遇到相同最大值时不更新 IMAX，因为比较使用严格大于号；DONE 在第 N 个数处理后拉高一拍…

**RTL 文件：**`MaxMin.v`。

**TB 文件：**
- `MaxMin_tb.v`（顶层 `MaxMin_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
