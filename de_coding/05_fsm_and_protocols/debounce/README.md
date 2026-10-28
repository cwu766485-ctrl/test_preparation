# 按键去抖

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `debounce`，RTL 顶层/子模块为 `debounce`, `debounce`。 源文件说明：计数器从 0 计到 CNT_MAX-1；即使 CNT_MAX=1，计数器宽度也至少保留 1 位。

**RTL 文件：**`debounce.sv`, `debounce.v`。

**TB 文件：**
- `tb_debounce_smoke.v`（顶层 `tb_debounce_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
