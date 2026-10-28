# 减法器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `subtractor`，RTL 顶层/子模块为 `subtractor`。 源文件说明：带借位输入的减法器。优点：可直接作为多位减法的基本单元。缺点：长链中的借位传播可能限制时序。

**RTL 文件：**`subtractor.v`。

**TB 文件：**
- `tb_subtractor_smoke.v`（顶层 `tb_subtractor_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
