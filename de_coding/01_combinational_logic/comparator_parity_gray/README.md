# comparator parity gray

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `comparator parity gray`，RTL 顶层/子模块为 `bin_gray`, `comparator`, `parity_gen`。

**RTL 文件：**`bin_gray.v`, `comparator.v`, `parity_gen.v`。

**TB 文件：**
- `tb.sv`（顶层 `tb_q4_q5_q6`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_bin_gray_smoke.v`（顶层 `tb_bin_gray_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_comparator_smoke.v`（顶层 `tb_comparator_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_parity_gen_smoke.v`（顶层 `tb_parity_gen_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
