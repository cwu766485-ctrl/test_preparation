# tb

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `tb`，RTL 顶层/子模块为 见 RTL 文件中的 module 声明。 源文件说明：Exhaust all 2^3 input combinations.

**RTL 文件：**`adder_agent.sv`, `adder_driver.sv`, `adder_env.sv`, `adder_if.sv`, `adder_item.sv`, `adder_monitor.sv`, `adder_pkg.sv`, `adder_scoreboard.sv`, `adder_sequence.sv`, `adder_test.sv`。

**TB 文件：**
- `tb_top.sv`（顶层 `tb_top`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make -C .. run
make -C .. clean
```

使用父目录的 UVM Makefile；请在课程配置好的 VCS/UVM 环境中运行。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
