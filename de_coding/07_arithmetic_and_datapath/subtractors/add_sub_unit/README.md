# 加减法单元

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `add sub unit`，RTL 顶层/子模块为 `add_sub_unit`。 源文件说明：统一无符号加减法单元，减法时 carry_out 表示没有借位。优点：加法和减法复用一个加法器，适合构成 ALU。缺点：控制逻辑和共享算术路径可能影响时序。

**RTL 文件：**`add_sub_unit.v`。

**TB 文件：**
- `tb_add_sub_unit_smoke.v`（顶层 `tb_add_sub_unit_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
