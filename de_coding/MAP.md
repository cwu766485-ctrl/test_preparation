# `de_coding/` 内容地图

这个目录按数字 IC 设计主题整理。每个练习小目录的 `README.md` 说明 RTL/TB 结构、VCS 入口和清理命令；报告写作/综合/门级仿真/Innovus 流程见 [`tools/EXAM_REPORT_GUIDE.md`](tools/EXAM_REPORT_GUIDE.md)。

## 按主题查找

| 目录 | 内容 | 入口 |
|---|---|---|
| 01 | 组合逻辑：加法器、移位器、比较器、校验、MUX、编码器 | [01_combinational_logic](01_combinational_logic/README.md) |
| 02 | 时序逻辑：计数器、DFF、边沿/分频、序列检测、移位寄存器 | [02_sequential_logic](02_sequential_logic/README.md) |
| 03 | CDC：同步器、Gray 指针、脉冲/中断、复位同步、无毛刺时钟切换 | [03_clock_domain_crossing](03_clock_domain_crossing/README.md) |
| 04 | RAM、FIFO、串并转换 | [04_memory_and_interfaces](04_memory_and_interfaces/README.md) |
| 05 | FSM、密码锁、去抖、PWM、握手、售货机 | [05_fsm_and_protocols](05_fsm_and_protocols/README.md) |
| 06 | 仲裁器、时钟分频、CRC-8、LFSR、数码管、LUT、UART RX | [06_advanced_topics_and_systems](06_advanced_topics_and_systems/README.md) |
| 07 | 加减法、ALU、串行数据通路、点积/矩阵、乘除法、移位 | [07_arithmetic_and_datapath](07_arithmetic_and_datapath/README.md) |
| Test2 | 29 个按题号组织的练习与考试模板 | [Test2](Test2/README.md) |

## NM6008 重点实例

- [Test2/17 可变位宽串行加法器](Test2/17_可变位宽串行加法器/README.md)：与附带的学长报告 最接近，详细说明 IDLE/RUN、逐位全加器、TB、波形、综合和报告。
- [Module 5 有符号矩阵乘法器](07_arithmetic_and_datapath/nm6008_matrix_multiplier/README.md)：接口采用手册中的 `MatrixMultiplier`、`A/B[7:0]`、`OUT[16:0]` 和 `OUT_STROBE`。
- [Secret Code 数字发生器](07_arithmetic_and_datapath/secretcode/README.md)：说明题目发生器与旧 keypad password-lock 练习的区别；考试按题面用 [`assignment/`](07_arithmetic_and_datapath/secretcode/assignment/README.md)。
- [考试报告与 Module 3/6 流程](tools/EXAM_REPORT_GUIDE.md)：波形、Design Vision、SDF 门级仿真、报告截图和 PDK 限制。

## Test2 题号速查

- 01 [四位加法器](Test2/01_四位加法器/README.md) · 02 [101 Moore 序列检测器](Test2/02_101序列检测器_Moore型/README.md) · 03 [四位计数器](Test2/03_四位计数器/README.md) · 04 [101 Mealy 序列检测器](Test2/04_101序列检测器_Mealy型/README.md) · 05 [状态机寄存器输出](Test2/05_状态机寄存器输出/README.md)
- 06 [全加器 56 种跳变](Test2/06_全加器56种跳变/README.md) · 07 [无符号矩阵乘法器](Test2/07_无符号矩阵乘法器/README.md) · 08 [三项点积](Test2/08_三项点积/README.md) · 09 [乘累加器](Test2/09_乘累加器/README.md) · 10 [四位 ALU](Test2/10_四位算术逻辑单元/README.md)
- 11 [四位比较器](Test2/11_四位比较器/README.md) · 12 [四选一 MUX](Test2/12_四选一多路选择器/README.md) · 13 [四位移位寄存器](Test2/13_四位移位寄存器/README.md) · 14 [四位 LFSR](Test2/14_四位线性反馈移位寄存器/README.md) · 15 [时钟分频器](Test2/15_时钟分频器/README.md)
- 16 [代码改错](Test2/16_代码改错/README.md) · 17 [可变位宽串行加法器](Test2/17_可变位宽串行加法器/README.md) · 18 [移位相加乘法器](Test2/18_移位相加乘法器/README.md) · 19 [位串行加减法器](Test2/19_位串行加减法器/README.md) · 20 [移位相减除法器](Test2/20_移位相减除法器/README.md)
- 21 [位串行比较器](Test2/21_位串行比较器/README.md) · 22 [2×2 矩阵乘向量](Test2/22_二乘二矩阵乘向量/README.md) · 23 [求和与平均值](Test2/23_求和与平均值/README.md) · 24 [最大最小值与位置](Test2/24_最大最小值与位置/README.md) · 25 [交通灯控制器](Test2/25_交通灯控制器/README.md)
- 26 [自动售货机](Test2/26_自动售货机/README.md) · 27 [可变位宽串行减法器](Test2/27_可变位宽串行减法器/README.md) · 28 [M345 模块化串行加法器](Test2/28_M345模块化串行加法器/README.md) · 29 [八位同步复位串行加法器](Test2/29_八位同步复位串行加法器/README.md)

## 常用命令

在题目目录运行：

```sh
make test
make clean
```

完整回归脚本和 Rocky Linux VCS 桥接在 [`tools/`](tools/README.md)。仿真覆盖是测试证据，不是形式验证或对所有输入/工艺角的证明。
## NM6008 Mock3–Mock7（按主题归档）

- [Mock3：时序 2×2 矩阵乘法器](07_arithmetic_and_datapath/matrix_mul_2x2_seq/README.md)
- [Mock4：8 位串行乘法器](07_arithmetic_and_datapath/multipliers/seq_multiplier8/README.md)
- [Mock5：行人交通灯控制器](05_fsm_and_protocols/ped_traffic_ctrl/README.md)
- [Mock6：带反压保持的 4 路轮询仲裁器](06_advanced_topics_and_systems/arbiter/rr_arbiter4_hold/README.md)
- [Mock7：带帧边界的 XOR 校验器](06_advanced_topics_and_systems/packet_xor_check/README.md)

每个题目目录都有 RTL 结构说明、TB 覆盖说明、VCS Makefile 和 clean 命令。全套回归可在 de_coding 下运行 bash tools/run_mock3_to_mock7_vcs.sh。
