# 20_移位相减除法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `20_移位相减除法器`，RTL 顶层/子模块为 `ShiftSubDiv`。 源文件说明：第20题：无符号移位相减除法器。A 是被除数，B 是除数；Q=A/B，R=A%B。 START 仅在空闲时接受，同时锁存 A、B；运行中 START 无效。此后逐拍处理 A 的位，从最高位开始。 每拍将旧余数左移并移入下一位，得到 trial；若 trial>=B，就减去 B，商该位为 1；否则余数保持，商该位为 0…

**RTL 文件：**`ShiftSubDiv.v`。

**TB 文件：**
- `ShiftSubDiv_tb.v`（顶层 `ShiftSubDiv_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
