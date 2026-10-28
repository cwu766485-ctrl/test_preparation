# 17_可变位宽串行加法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**复用一个 1 位全加器和 FSM/计数器，逐位处理最多 16 位输入；TB 覆盖 N=1..16、进位、锁存、DONE 和边界值。

**RTL 文件：**`SerialAdder.v`。

**TB 文件：**
- `SerialAdder_tb.v`（顶层 `SerialAdder_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
