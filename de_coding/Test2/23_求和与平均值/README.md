# 23_求和与平均值

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `23_求和与平均值`，RTL 顶层/子模块为 `SumAvg`。 源文件说明：第23题：连续接收 N=8 个无符号 8 位数，每拍一个；START 与第一个数同拍，仅空闲时有效。 后续 N-1 拍不能留空；SUM 为总和，AVG 为向下取整的平均值，AVG_R 为四舍五入的平均值。 八个最大输入 255 的和是 2040，11 位足够；除以 8 相当于右移 3 位…

**RTL 文件：**`SumAvg.v`。

**TB 文件：**
- `SumAvg_tb.v`（顶层 `SumAvg_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
