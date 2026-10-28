# 流水线算术逻辑单元

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `pipelined alu`，RTL 顶层/子模块为 `pipelined_alu`。 源文件说明：一级寄存式 ALU。优点：寄存器隔离组合逻辑延迟并对齐 valid 时序。缺点：增加一个周期延迟并占用触发器资源。

**RTL 文件：**`pipelined_alu.v`。

**TB 文件：**
- `tb_pipelined_alu_smoke.v`（顶层 `tb_pipelined_alu_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
