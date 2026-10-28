# 简易算术逻辑单元

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `simple alu`，RTL 顶层/子模块为 `simple_alu`。 源文件说明：无符号简易 ALU。减法时，carry_out=1 表示未发生借位。优点：展示加减和逻辑运算共用数据通路控制。缺点：单周期组合实现的关键路径可能较长。

**RTL 文件：**`simple_alu.v`。

**TB 文件：**
- `tb_simple_alu_smoke.v`（顶层 `tb_simple_alu_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
