# Wallace 树乘法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `wallace multiplier`，RTL 顶层/子模块为 `wallace_compressor_tree`, `wallace_multiplier`。 源文件说明：每一级把部分积行按三行一组压缩为两行，构成 Wallace 树。

**RTL 文件：**`wallace_compressor_tree.v`, `wallace_multiplier.v`。

**TB 文件：**
- `tb_wallace_compressor_tree_smoke.v`（顶层 `tb_wallace_compressor_tree_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_wallace_multiplier_smoke.v`（顶层 `tb_wallace_multiplier_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
