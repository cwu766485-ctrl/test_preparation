# pipelined divider

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `pipelined divider`，RTL 顶层/子模块为 `pipelined_divider`。 源文件说明：Fully pipelined unsigned restoring divider with one quotient-bit stage per bit. Advantage: accepts one input per cycle after pipeline fill. Disadvantage: uses WIDTH registered…

**RTL 文件：**`pipelined_divider.v`。

**TB 文件：**
- `tb_pipelined_divider_smoke.v`（顶层 `tb_pipelined_divider_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
