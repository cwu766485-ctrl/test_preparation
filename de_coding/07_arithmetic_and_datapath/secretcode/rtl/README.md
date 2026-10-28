# rtl

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**旧 keypad password-lock 练习，输入为 key_valid/key_data 并带失败报警；不是题目要求的数字发生器。

**RTL 文件：**`secretcode.v`, `Syn_FullAdder.v`, `Syn_secretcode.v`。

**TB 文件：**
- `FullAdder_tb.v`（顶层 `FullAdder_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `FullAdder_tb_auto.v`（顶层 `FullAdder_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `secretcode_tb.v`（顶层 `secretcode_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
cd de_coding
bash tools/run_secretcode_vcs.sh
```

该回归会运行 assignment number-generator 与 legacy keypad 示例；它们是不同题目。脚本用临时目录并自动清理。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
