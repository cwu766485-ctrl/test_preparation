# D 触发器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `dff`，RTL 顶层/子模块为 `dff_async`, `dff_sync_en`, `dff_async`, `dff_sync_en`。

**RTL 文件：**`dff.sv`, `dff.v`。

**TB 文件：**
- `tb_dff_async_smoke.v`（顶层 `tb_dff_async_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_dff_sync_en_smoke.v`（顶层 `tb_dff_sync_en_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
