# 中断跨时钟域传输

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `interrupt cdc`，RTL 顶层/子模块为 `interrupt_cdc`, `interrupt_cdc`。 源文件说明：中断事件跨时钟域传输：源端仅在 irq_ready=1 时接受 irq_event；目的端锁存事件，直到外设或软件逻辑发出 irq_clear。

**RTL 文件：**`interrupt_cdc.sv`, `interrupt_cdc.v`。

**TB 文件：**
- `tb_interrupt_cdc_smoke.v`（顶层 `tb_interrupt_cdc_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
