# 18_移位相加乘法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `18_移位相加乘法器`，RTL 顶层/子模块为 `ShiftAddMul`。 源文件说明：第18题：无符号移位相加乘法器。START 装入 A、B；随后 W 个时钟每拍看 b_sh[0]，若为 1 就把当前左移后的 A 加到部分积。A 每拍左移，B 每拍右移，只复用一个 2W 位加法器。最后一拍把 acc_next 写入 P，并把 DONE 拉高一拍。

**RTL 文件：**`ShiftAddMul.v`。

**TB 文件：**
- `ShiftAddMul_tb.v`（顶层 `ShiftAddMul_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
