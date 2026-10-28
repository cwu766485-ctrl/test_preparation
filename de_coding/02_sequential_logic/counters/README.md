# 计数器模式

本目录提供三种回绕行为不同的计数器：

- cnt_up：en=1 时递增。WIDTH=4 时按 0 到 15 计数，再回到 0。
- cnt_down：en=1 时递减。WIDTH=4 时按 0、15、14……计数，从 0 回绕到 15。
- cnt_modN：en=1 时递增，并在 N-1 后回到 0。N=10 时计数范围为 0 到 9；4 位向上计数器会继续计到 15。

因此，mod-N 模式相当于把回绕点设为 N-1 的向上计数器；只有 N=2^WIDTH 时，才与自然溢出的 WIDTH 位向上计数器序列相同。

三个计数器都采用低有效异步复位。cnt_modN.tc 在当前计数等于 N-1 时为高，即使计数器暂停也保持该状态。

## 运行 VCS 测试

在已配置 VCS 的 Linux/WSL 终端中，于本目录运行：

~~~sh
make
make test_cnt_up
make test_cnt_down
make test_cnt_modN
make clean
~~~

本目录的 RTL、TB 和考试命令速查见下方。
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
