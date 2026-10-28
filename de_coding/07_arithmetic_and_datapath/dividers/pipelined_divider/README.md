# 流水线除法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `pipelined divider`，RTL 顶层/子模块为 `pipelined_divider`。 源文件说明：全流水无符号恢复余数除法器，每一位商对应一级流水。优点：流水线填满后每周期可接收一个输入。缺点：需要 WIDTH 级寄存器，面积开销较大。

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
