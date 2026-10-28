# 11_四位比较器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `11_四位比较器`，RTL 顶层/子模块为 `Comparator4`。 源文件说明：第11题：4 位无符号比较器。GT、EQ、LT 分别表示 A 大于、等于、小于 B；有效二进制输入下，三个输出恰好一个为 1。这里按无符号数比较；若题目要求有符号数，需修改端口类型或显式进行有符号转换。

**RTL 文件：**`Comparator4.v`。

**TB 文件：**
- `Comparator4_tb.v`（顶层 `Comparator4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
