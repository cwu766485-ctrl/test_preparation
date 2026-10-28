# 06_全加器56种跳变

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `06_全加器56种跳变`，RTL 顶层/子模块为 `FullAdder`。 源文件说明：1 位全加器：S 为 A、B、CIN 三个输入相加后的最低位；COUT 为进位。与 Module 3 的电路相同。

**RTL 文件：**`FullAdder.v`。

**TB 文件：**
- `FullAdder_tb_all.v`（顶层 `FullAdder_tb_all`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
