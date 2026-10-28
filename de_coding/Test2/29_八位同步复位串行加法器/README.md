# 29_八位同步复位串行加法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `29_八位同步复位串行加法器`，RTL 顶层/子模块为 `FullAdder`, `SerialAdder8`, `SerialAdder8Controller`。 源文件说明：M3: 1 位全加器。串行加法器每个时钟周期复用同一个实例。

**RTL 文件：**`FullAdder.v`, `SerialAdder8.v`, `SerialAdder8Controller.v`。

**TB 文件：**
- `SerialAdder8_tb.v`（顶层 `SerialAdder8_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
