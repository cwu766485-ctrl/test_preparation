# sync fifo

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `sync fifo`，RTL 顶层/子模块为 `sync_fifo`, `sync_fifo`。

**RTL 文件：**`sync_fifo.sv`, `sync_fifo.v`。

**TB 文件：**
- `tb_sync_fifo.sv`（顶层 `tb_sync_fifo`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_sync_fifo_smoke.v`（顶层 `tb_sync_fifo_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
