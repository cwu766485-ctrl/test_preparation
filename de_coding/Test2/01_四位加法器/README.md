# 01_四位加法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `01_四位加法器`，RTL 顶层/子模块为 `Adder4`, `FullAdder`。 源文件说明：第 1 题：用四个 1 位全加器串接，构成 4 位脉动进位加法器。 顶层模块名为 Adder4；综合脚本中指定的顶层名称也必须一致。

**RTL 文件：**`Adder4.v`, `FullAdder.v`。

**TB 文件：**
- `Adder4_tb.v`（顶层 `Adder4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
