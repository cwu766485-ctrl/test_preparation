# Serial Adder 8 Sync Reset

RTL: `serial_adder_8_sync_reset.v`  
Testbench: `tb_serial_adder_8_sync_reset.v`  
Top module: `serial_adder_8_sync_reset`

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

**设计说明：**本题练习 `serial adder 8 sync reset`，RTL 顶层/子模块为 `serial_adder_8_sync_reset`。 源文件说明：Fixed eight-bit unsigned serial adder with active-high synchronous reset.

**RTL 文件：**`serial_adder_8_sync_reset.v`。

**TB 文件：**
- `tb_serial_adder_8_sync_reset.v`（顶层 `tb_serial_adder_8_sync_reset`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
