# 选择进位加法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `carry select adder`，RTL 顶层/子模块为 `carry_select_adder`。 源文件说明：选择进位加法器。优点：并行计算两种进位情况下的结果，可降低延迟。缺点：复制加法器会增加面积和功耗。

**RTL 文件：**`carry_select_adder.v`。

**TB 文件：**
- `tb_carry_select_adder_smoke.v`（顶层 `tb_carry_select_adder_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
