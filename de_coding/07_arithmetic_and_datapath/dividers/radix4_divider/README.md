# 基 4 除法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `radix4 divider`，RTL 顶层/子模块为 `radix4_divider`。 源文件说明：迭代式无符号基 4 恢复余数除法器。优点：每次迭代选择两位商，约需 WIDTH/2 次迭代。缺点：每步需要多种倍数比较和减法逻辑。

**RTL 文件：**`radix4_divider.v`。

**TB 文件：**
- `tb_radix4_divider_smoke.v`（顶层 `tb_radix4_divider_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
