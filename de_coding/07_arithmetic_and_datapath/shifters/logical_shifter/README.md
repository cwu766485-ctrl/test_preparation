# logical shifter

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `logical shifter`，RTL 顶层/子模块为 `logical_shifter`。 源文件说明：Logical left/right shifter. Advantage: simple combinational implementation for unsigned data. Disadvantage: right shift always inserts zeros and cannot preserve sign. dir=1 shifts…

**RTL 文件：**`logical_shifter.v`。

**TB 文件：**
- `tb_logical_shifter_smoke.v`（顶层 `tb_logical_shifter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
