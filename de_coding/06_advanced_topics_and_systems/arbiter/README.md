# 仲裁器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `arbiter`，RTL 顶层/子模块为 `credit_qos_arbiter`, `credit_qos_arbiter`, `round_robin_arbiter`, `round_robin_arbiter`, `strict_priority_arbiter`, `strict_priority_arbiter`, `weighted_round_robin_arbiter`, `weighted_round_robin_arbiter`。 源文件说明：基于额度的 QoS 仲裁器：每隔 REPLENISH_PERIOD 个周期补充额度；在额度充足的请求者中按轮询顺序授权，成功接受的授权会消耗相应额度。

**RTL 文件：**`credit_qos_arbiter.sv`, `credit_qos_arbiter.v`, `round_robin_arbiter.sv`, `round_robin_arbiter.v`, `strict_priority_arbiter.sv`, `strict_priority_arbiter.v`, `weighted_round_robin_arbiter.sv`, `weighted_round_robin_arbiter.v`。

**TB 文件：**
- `tb_credit_qos_arbiter_smoke.v`（顶层 `tb_credit_qos_arbiter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_round_robin_arbiter_smoke.v`（顶层 `tb_round_robin_arbiter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_strict_priority_arbiter_smoke.v`（顶层 `tb_strict_priority_arbiter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。
- `tb_weighted_round_robin_arbiter_smoke.v`（顶层 `tb_weighted_round_robin_arbiter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
