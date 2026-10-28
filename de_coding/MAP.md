# `de_coding` 内容地图

这里按主题查找 RTL、testbench、Makefile 和练习资料。原始 RTL/TB 通常放在各练习目录内；仿真入口以对应目录的 `Makefile` 为准。

## 按主题查找

| 目录 | 内容 |
|---|---|
| [`01_combinational_logic/`](01_combinational_logic/) | 组合逻辑：加法器 UVM、桶形移位器、比较器、奇偶校验/Gray、前导零计数、MUX、popcount、优先编码器 |
| [`02_sequential_logic/`](02_sequential_logic/) | 时序逻辑：计数器（up/down/mod-N）、DFF、边沿检测、奇偶分频、无毛刺时钟 MUX、101 序列检测（Mealy/Moore）、移位寄存器、状态序列 |
| [`03_clock_domain_crossing/`](03_clock_domain_crossing/) | CDC：bit/多位同步器、Gray 指针、脉冲同步、复位同步、中断同步、无毛刺时钟切换 |
| [`04_memory_and_interfaces/`](04_memory_and_interfaces/) | 存储与接口：异步双口 RAM、同步/异步 FIFO、串并/并串转换 |
| [`05_fsm_and_protocols/`](05_fsm_and_protocols/) | FSM 与协议：Moore/Mealy、密码锁、去抖、脉宽测量、PWM、req/ack 握手、1011 检测、状态机寄存器输出、自动售货机 |
| [`06_advanced_topics_and_systems/`](06_advanced_topics_and_systems/) | 进阶模块：仲裁器、时钟分频、CRC-8、LFSR、数码管扫描、正弦 LUT、UART RX |
| [`07_arithmetic_and_datapath/`](07_arithmetic_and_datapath/) | 算术/数据通路：各类加法器、ALU、串行加减法、代码改错、除法器、点积、矩阵乘向量、最大最小值、乘法器、串行比较/加减、移位器、求和与平均值 |

## 逐目录索引

### 01 组合逻辑

`adders_uvm`、`barrel_shifter`、`comparator`、`comparator_parity_gray`、`leading_zero_count`、`mux_implementations`、`mux_variants`、`parity_generator`、`popcount`、`priority_encoder`。

### 02 时序逻辑

`counters`、`dff`、`edge_detect`、`even_divider`、`glitch_free_clock_mux`、`odd_divider`、`sequence_101`、`sequence_101_moore`、`shift_registers`、`state_sequence`。

### 03 CDC

`bit_synchronizer`、`glitch_free_clock_switch`、`gray_pointer`、`interrupt_cdc`、`multi_bit_synchronizer`、`pulse_sync`、`reset_synchronizer`。

### 04 存储与接口

`async_dual_port_ram`、`async_fifo`、`parallel_to_serial`、`serial_to_parallel`、`sync_fifo`。

### 05 FSM 与协议

`debounce`、`moore_mealy_fsm/`（含 `3seg_fsm`、`mealy_fsm`、`moore_fsm`）、`password_lock`、`pulse_width`、`pwm`、`req_ack_handshake`、`sequence_1011`、`state_machine_regout`、`vending_machine`。

### 06 进阶主题

`arbiter`、`clock_dividers`、`crc8`、`lfsr`、`seven_segment_scan`、`sine_lut`、`uart_rx`。

### 07 算术与数据通路

- `adders/`：carry-lookahead、carry-select、full/half、prefix、ripple-carry。
- `alu/`：pipelined ALU、simple ALU。
- 独立练习：`bit_serial_add_sub`、`code_debug`、`dot_product3`、`matvec_2x2`、`max_min_index`、`modular_serial_adder`、`serial_adder`、`serial_adder_8_sync_reset`、`serial_comparator`、`serial_subtractor`、`sum_average`。
- `dividers/`：non-restoring、pipelined、radix-4、restoring。
- `multipliers/`：array、Booth、matrix、pipelined、shift-add、Wallace。
- `shifters/`：arithmetic、barrel、funnel、logical、rotate。
- `subtractors/`：add/sub unit、saturating subtractor、subtractor。
- `secretcode/`：行为级 RTL/TB、RTL 与综合网表练习；PDK 库和仿真产物不纳入 GitHub 副本。

## `Test2/` 题目索引

`00_一键流程脚本` 与 `00_*模板` 是考试流程/模板；`01`–`29` 是按题号查找的练习：

1. 四位加法器　2. 101 Moore 序列检测　3. 四位计数器　4. 101 Mealy 序列检测
5. 状态机寄存器输出　6. 全加器 56 种跳变　7. 无符号矩阵乘法器　8. 三项点积
9. 乘累加器　10. 四位 ALU　11. 四位比较器　12. 四选一 MUX
13. 四位移位寄存器　14. 四位 LFSR　15. 时钟分频器　16. 代码改错
17. 可变位宽串行加法器　18. 移位相加乘法器　19. 位串行加减法器　20. 移位相减除法器
21. 位串行比较器　22. 2×2 矩阵乘向量　23. 求和与平均值　24. 最大/最小值与位置
25. 交通灯控制器　26. 自动售货机　27. 可变位宽串行减法器　28. M345 模块化串行加法器
29. 八位同步复位串行加法器。

## 工具与验证入口

- [`tools/VCS_USAGE.md`](tools/VCS_USAGE.md)：Linux/WSL 下的 VCS 命令和单目录 Makefile 用法。
- [`tools/run_vcs_all.sh`](tools/run_vcs_all.sh)：运行 Makefile 汇总回归。
- [`tools/run_sv_vcs.sh`](tools/run_sv_vcs.sh)：SystemVerilog testbench 回归。
- [`tools/run_test2_vcs.sh`](tools/run_test2_vcs.sh)：Test2 回归（代码改错题按预期检测错误）。
- [`tools/run_missing_code_vcs.sh`](tools/run_missing_code_vcs.sh)：补充模块回归。
- [`tools/run_secretcode_vcs.sh`](tools/run_secretcode_vcs.sh)：secretcode 相关回归。
- [`tools/rocky-bridge.tasks.json`](tools/rocky-bridge.tasks.json)：Rocky Linux WSL 任务定义。
- [`tools/vcs_summary.tsv`](tools/vcs_summary.tsv)：最近一次 VCS 汇总记录。
- [`question_index.md`](question_index.md)、[`README.md`](README.md)：题目与目录背景。

最近一次记录显示 `vcs_summary.tsv` 中 91 个 VCS Makefile 目标均 PASS、0 条 warning；另有 59 个 SystemVerilog TB 和 30 个常规 Test2 用例通过。Test2 的 6 个代码改错用例按设计应报告检测到错误。仿真覆盖不能替代形式验证，也不保证未覆盖的所有输入/工艺条件；涉及 PDK 的综合网表只按脚本列出的配置做了可用范围内的编译/仿真。

## GitHub 副本范围

上传到 `test_preparation/de_coding/` 的副本保留 RTL、TB、Makefile、考试练习、脚本和文档；忽略仿真构建缓存/波形/日志，以及商业工艺库、综合数据库、参考 PDF 等本地或受限材料。带有本地环境配置的 Synopsys 启动文件也不复制。

## 快速定位

在 `de_coding/` 根目录执行：

```sh
rg --files -g '*.v' -g '*.sv'             # 列出 Verilog/SystemVerilog 文件
rg -n 'module[[:space:]]+模块名' .         # 按模块名查 RTL
rg --files -g 'Makefile'                  # 找可单独运行的仿真入口
```

单个练习目录的常见命令：

```sh
cd 02_sequential_logic/counters
make                 # 编译并运行该目录默认仿真
make clean           # 清理该目录的 VCS 生成物
```

总回归命令和详细前置条件见 `tools/VCS_USAGE.md`。需先进入配置好 VCS 环境的 Linux/WSL shell。
