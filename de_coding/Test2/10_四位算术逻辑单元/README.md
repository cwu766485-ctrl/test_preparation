# 10_四位算术逻辑单元

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `10_四位算术逻辑单元`，RTL 顶层/子模块为 `ALU4`。 源文件说明：第10题：4 位组合算术逻辑单元。OP=00 加法，01 减法，10 按位与，11 按位或。Y 保存低 4 位；加法时 C 是进位，减法时 C=1 表示无符号借位；Z=1 表示 Y 为零。组合逻辑先给 Y、C 默认值，再按 OP 覆盖，避免输出保持旧值而推断锁存器。

**RTL 文件：**`ALU4.v`。

**TB 文件：**
- `ALU4_tb.v`（顶层 `ALU4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
