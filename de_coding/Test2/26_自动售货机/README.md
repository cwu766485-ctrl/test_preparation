# 26_自动售货机

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `26_自动售货机`，RTL 顶层/子模块为 `VendingMachine`。 源文件说明：第26题：售货机状态机，商品价格 15 分；NICKEL 表示投入 5 分，DIME 表示投入 10 分。 每种投币信号保持一拍；若同拍两种币都为 1，视为无效且维持当前余额。 S0/S5/S10 分别代表当前累计 0/5/10 分；达到 15 分出货并清零，达到 20 分还找 5 分…

**RTL 文件：**`VendingMachine.v`。

**TB 文件：**
- `VendingMachine_tb.v`（顶层 `VendingMachine_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
