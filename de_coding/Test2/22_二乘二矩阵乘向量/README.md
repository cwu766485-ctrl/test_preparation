# 22_二乘二矩阵乘向量

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `22_二乘二矩阵乘向量`，RTL 顶层/子模块为 `MatVec2x2`。 源文件说明：第22题：2×2 有符号矩阵乘 2×1 向量；Y0=M00*X0+M01*X1，Y1=M10*X0+M11*X1。 A、B 共用两条 8 位输入总线，每拍输入一对；每次运算固定四拍。 cnt=0 输入 M00/X0；cnt=1 输入 M01/X1，得到第一行；cnt=2 输入 M10/X0；cnt=3 输入 M11/X1…

**RTL 文件：**`MatVec2x2.v`。

**TB 文件：**
- `MatVec2x2_tb.v`（顶层 `MatVec2x2_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
