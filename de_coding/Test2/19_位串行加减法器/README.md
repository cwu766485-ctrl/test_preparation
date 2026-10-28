# 19_位串行加减法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `19_位串行加减法器`，RTL 顶层/子模块为 `BitSerialAddSub`。 源文件说明：第19题：位串行加减法器。A、B 每拍各输入一位，最低位先到；不是一次装入整字。 FIRST 与新字最低位同时为 1，使本字从正确的初始进位开始；SUB 在一个字内保持不变。 SUB=0 算 A+B，最低位进位为 0；SUB=1 算 A-B，即 A+(~B)+1，最低位进位为 1…

**RTL 文件：**`BitSerialAddSub.v`。

**TB 文件：**
- `BitSerialAddSub_tb.v`（顶层 `BitSerialAddSub_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
