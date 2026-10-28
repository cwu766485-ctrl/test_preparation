# 27_可变位宽串行减法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `27_可变位宽串行减法器`，RTL 顶层/子模块为 `SerialSubtractor`。 源文件说明：第27题：仿照第17题的可变位宽串行减法器，计算 A-B。 START 在空闲时锁存两个操作数和位数 N；随后从最低位到最高位，每拍复用同一个 1 位减法器。 borrow 保存上一位向本位借来的 1；当前差值位写入 DIFF[cnt]，并将 A/B 右移供下一拍使用…

**RTL 文件：**`SerialSubtractor.v`。

**TB 文件：**
- `SerialSubtractor_tb.v`（顶层 `SerialSubtractor_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
