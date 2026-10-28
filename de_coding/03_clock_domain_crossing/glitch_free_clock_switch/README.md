# 无毛刺时钟切换

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `glitch free clock switch`，RTL 顶层/子模块为 `glitch_free_clock_switch`, `glitch_free_clock_switch_ownership`, `glitch_free_clock_switch`, `glitch_free_clock_switch_ownership`。 源文件说明：无毛刺时钟多路选择示例：先在当前时钟的下降沿关闭它，再开启另一路。切换时 clk_out 可能暂停数个周期；两路输入时钟必须符合模块规定的时钟条件。

**RTL 文件：**`glitch_free_clock_switch.sv`, `glitch_free_clock_switch.v`。

**TB 文件：**
- `tb_glitch_free_clock_switch_ownership_smoke.v`（顶层 `tb_glitch_free_clock_switch_ownership_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_glitch_free_clock_switch_smoke.v`（顶层 `tb_glitch_free_clock_switch_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
