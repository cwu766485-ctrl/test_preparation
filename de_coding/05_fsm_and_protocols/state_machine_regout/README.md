# State Machine Regout

RTL: `state_machine_regout.v`  
Testbench: `tb_state_machine_regout.v`  
Top module: `state_machine_regout`

## Exam commands (Linux / Rocky Linux)

From this directory, compile and run with VCS:

```sh
make
```

A successful self-check prints `PASS:`. Remove compiler and simulator outputs with:

```sh
make clean
```

If the Synopsys environment is not initialized in the exam lab, source the lab-provided setup script before running `make`.

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `state machine regout`，RTL 顶层/子模块为 `state_machine_regout`。 源文件说明：Four-state example FSM with registered sum/carry outputs.

**RTL 文件：**`state_machine_regout.v`。

**TB 文件：**
- `tb_state_machine_regout.v`（顶层 `tb_state_machine_regout`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
