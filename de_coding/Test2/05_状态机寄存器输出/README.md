# 05_状态机寄存器输出

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `05_状态机寄存器输出`，RTL 顶层/子模块为 `StateMachine`。 源文件说明：第 5 题：Module 4 状态机，输出 S 和 COUT 由寄存器驱动，避免组合毛刺。 对应 Module 4 的可选进阶题。 状态转移规则沿用 Module 4： S0 收到 start 转 S1；S1/S2/S3 收到 rst 回 S0；否则依次 S1→S2→S3→S1。 S 在 S1 或 S3 时为 A、B、CIN 的全加器和位，其他状态为 0…

**RTL 文件：**`StateMachine.v`。

**TB 文件：**
- `StateMachine_tb.v`（顶层 `StateMachine_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
