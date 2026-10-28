# 前缀加法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `prefix adder`，RTL 顶层/子模块为 `prefix_adder`, `prefix_adder_stage`。 源文件说明：参数化 Kogge-Stone 前缀加法器。优点：进位逻辑深度为对数级。缺点：密集的前缀网络比行波进位加法器需要更多布线和面积。

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
