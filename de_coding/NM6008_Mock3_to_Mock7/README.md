# NM6008 Mock3–Mock7 练习索引

原 Mock3–Mock7 RTL/TB 已按电路主题归入 de_coding 的 05、06、07 目录。每个题目目录都有中文 README，说明接口、RTL 电路结构、TB 覆盖范围以及 VCS 验证命令。

| 题号 | 电路 | RTL 结构重点 | 归档目录 |
|---|---|---|---|
| Mock3 | 时序 2×2 矩阵乘法 | 单个乘法器和累加加法器逐项复用，FSM/计数器控制 8 次乘加 | [matrix_mul_2x2_seq](../07_arithmetic_and_datapath/matrix_mul_2x2_seq/README.md) |
| Mock4 | 8 位串行乘法器 | 移位相加、部分积寄存器、8 拍控制 | [seq_multiplier8](../07_arithmetic_and_datapath/multipliers/seq_multiplier8/README.md) |
| Mock5 | 行人交通灯控制器 | 四状态 FSM、tick 计时、待处理请求寄存器 | [ped_traffic_ctrl](../05_fsm_and_protocols/ped_traffic_ctrl/README.md) |
| Mock6 | 4 路轮询仲裁器 | 优先级指针、one-hot grant、反压授权保持 | [rr_arbiter4_hold](../06_advanced_topics_and_systems/arbiter/rr_arbiter4_hold/README.md) |
| Mock7 | 帧 XOR 校验器 | 帧协议控制、running XOR、饱和长度计数器 | [packet_xor_check](../06_advanced_topics_and_systems/packet_xor_check/README.md) |

## 统一验证

每个题目目录提供普通 Makefile。在 Rocky Linux/WSL 中进入对应目录运行：

    make test
    make clean

也可以在 de_coding 下运行：

    bash tools/run_mock3_to_mock7_vcs.sh

该脚本依次执行五组 VCS 行为级回归，并在每个题目后清理 build/。门级包装 TB 需要真实综合网表、对应 SDF 和工艺库模型；没有这些文件时不能当作门级验证完成。综合、SDF 和功耗报告流程见 [考试报告流程](../tools/EXAM_REPORT_GUIDE.md)。

这些 Mock 是练习题，不是官方考试题库。RTL 行为回归通过表示给定 TB 检查通过，不等于形式验证或工艺签核。
## 本次 VCS 回归结果

2026-10-28 在 Rocky Linux 8.10 WSL 使用 VCS V-2023.12-SP1 依次运行五个目录的 make test，五组均 PASS；每组之后都执行 make clean。Mock3 为 127 组事务/1264 次周期检查，Mock4 为 56 组乘法事务，Mock5 为 388 次检查，Mock6 为 268 次检查，Mock7 为 382 次检查。
