# 13_四位移位寄存器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `13_四位移位寄存器`，RTL 顶层/子模块为 `ShiftReg4`。 源文件说明：第13题：4 位串行输入、并行输出移位寄存器。NRST 拉低时无需时钟立即清零；EN=1 的每个上升沿，旧 Q[2:0] 移向高位，SIN 进入 Q[0]；EN=0 时保持。SOUT 始终连接 Q[3]。时序块使用非阻塞赋值，保证各触发器读取同一拍的旧值。

**RTL 文件：**`ShiftReg4.v`。

**TB 文件：**
- `ShiftReg4_tb.v`（顶层 `ShiftReg4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
