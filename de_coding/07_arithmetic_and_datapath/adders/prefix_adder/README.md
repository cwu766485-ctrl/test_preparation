# prefix adder

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `prefix adder`，RTL 顶层/子模块为 `prefix_adder`, `prefix_adder_stage`。 源文件说明：Parameterized Kogge-Stone prefix adder. Advantage: computes carries with logarithmic logic depth. Disadvantage: the dense prefix network uses more wiring and area than ripple…

**RTL 文件：**`prefix_adder.v`, `prefix_adder_stage.v`。

**TB 文件：**
- `tb_prefix_adder_smoke.v`（顶层 `tb_prefix_adder_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_prefix_adder_stage_smoke.v`（顶层 `tb_prefix_adder_stage_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
