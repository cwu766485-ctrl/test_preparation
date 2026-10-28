# Counter modes

This directory contains three counters with distinct wrap behavior:

- `cnt_up`: increments while `en` is high. With `WIDTH=4`, it counts 0 through 15, then wraps to 0.
- `cnt_down`: decrements while `en` is high. With `WIDTH=4`, it counts 0, 15, 14, ..., then wraps from 0 to 15.
- `cnt_modN`: increments while `en` is high and wraps from `N-1` to 0. For `N=10`, its sequence is 0 through 9. This differs from a 4-bit up-counter, which continues through 15.

All three use an active-low asynchronous reset. `cnt_modN.tc` is high whenever the current count equals `N-1`, including while the counter is disabled.

## Run the VCS tests

From this directory in Linux/WSL with VCS available:

```sh
make          # compile and run all three self-checking testbenches
make test_cnt_up
make test_cnt_down
make test_cnt_modN
make clean    # remove generated build files
```

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**包含向上计数、向下计数和 mod-N 计数实现；各自的 TB 分别验证计数方向、边界回绕和终端计数标志。

**RTL 文件：**`counters.sv`, `counters.v`。

**TB 文件：**
- `tb_cnt_down.v`（顶层 `tb_cnt_down`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_cnt_modN.v`（顶层 `tb_cnt_modN`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_cnt_up.v`（顶层 `tb_cnt_up`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
