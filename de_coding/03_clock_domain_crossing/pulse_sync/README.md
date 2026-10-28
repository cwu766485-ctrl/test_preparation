# pulse sync

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `pulse sync`，RTL 顶层/子模块为 `event_counter_cdc`, `event_counter_cdc`, `pulse_handshake`, `pulse_handshake`, `pulse_sync`, `pulse_sync`。 源文件说明：Counts source events modulo 2**COUNT_W, then transfers a Gray count. dst_delta reports how many events arrived since the previous destination sample. No event is lost IF fewer…

**RTL 文件：**`event_counter_cdc.sv`, `event_counter_cdc.v`, `pulse_handshake.sv`, `pulse_handshake.v`, `pulse_sync.sv`, `pulse_sync.v`。

**TB 文件：**
- `tb_event_counter_cdc_smoke.v`（顶层 `tb_event_counter_cdc_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_pulse_handshake_smoke.v`（顶层 `tb_pulse_handshake_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_pulse_sync_smoke.v`（顶层 `tb_pulse_sync_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
