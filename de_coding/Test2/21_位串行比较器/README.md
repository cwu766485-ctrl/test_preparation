# 21_位串行比较器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `21_位串行比较器`，RTL 顶层/子模块为 `SerialComparator`。 源文件说明：第21题：无符号位串行比较器。每拍输入 A、B 各一位，最高位先到；FIRST 与新字最高位同时为 1。 从高位往低位看，最先不相同的一位就决定大小，后续低位不再改变比较结果。 三个状态：S_EQ 表示目前相等，S_GT 表示 A 已确定较大，S_LT 表示 B 已确定较大…

**RTL 文件：**`SerialComparator.v`。

**TB 文件：**
- `SerialComparator_tb.v`（顶层 `SerialComparator_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
