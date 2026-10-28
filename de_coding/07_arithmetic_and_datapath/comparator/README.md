# 比较器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**固定四位 secret-code 比较器：Comparator 比较每个 3 位输入，Test2 汇总四个相等信号控制 open；本例只做比较，不负责生成候选数字。

**RTL 文件：**`Test2.v`。

**TB 文件：**
- `Test2_tb.v`（顶层 `tb_Test2`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
