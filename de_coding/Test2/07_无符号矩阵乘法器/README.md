# 07_无符号矩阵乘法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `07_无符号矩阵乘法器`，RTL 顶层/子模块为 `MatrixMultiplier`。 源文件说明：第 7 题：Module 5 的矩阵乘法器改为无符号版本。 输出计算 OUT=A1×B1+A0×B0；A、B 都是 0～255 的 8 位无符号数。 沿用 Module 5 的状态机、乘法器、累加器结构和时序； A1/B1 与 A0/B0 依次复用 A/B 输入总线，每组结果约五拍出现一次。 模块与端口名称保持原样，Module 5 的脚本无需改顶层名…

**RTL 文件：**`MatrixMultiplier.v`。

**TB 文件：**
- `MatrixMultiplier_tb.v`（顶层 `MatrixMultiplier_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
