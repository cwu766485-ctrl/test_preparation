# 复位同步器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `reset synchronizer`，RTL 顶层/子模块为 `dual_clock_reset_sync`, `dual_clock_reset_sync`, `reset_synchronizer`, `reset_synchronizer`。 源文件说明：两个互不相关时钟域的复位示例：async_rst_n 可立即异步拉低各域复位；各域复位只能在本域时钟有效沿同步释放。

**RTL 文件：**`dual_clock_reset_sync.sv`, `dual_clock_reset_sync.v`, `reset_synchronizer.sv`, `reset_synchronizer.v`。

**TB 文件：**
- `tb_dual_clock_reset_sync_smoke.v`（顶层 `tb_dual_clock_reset_sync_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_reset_synchronizer_smoke.v`（顶层 `tb_reset_synchronizer_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
