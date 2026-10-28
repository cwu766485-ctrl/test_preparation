# 09_乘累加器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `09_乘累加器`，RTL 顶层/子模块为 `MAC`。 源文件说明：第 9 题：乘累加器 MAC，逐拍计算多个乘积的总和。 每个 EN=1 的上升沿执行 ACC←ACC+A×B；A、B 为有符号 8 位数。 CLR=1 时同步清零 ACC，优先级高于 EN。 NRST=0 时异步清零 ACC，不等时钟上升沿…

**RTL 文件：**`MAC.v`。

**TB 文件：**
- `MAC_tb.v`（顶层 `MAC_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
