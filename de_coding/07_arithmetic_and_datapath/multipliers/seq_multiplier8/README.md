# Mock4：8 位移位相加串行乘法器

## 题目与接口

顶层模块 seq_multiplier8 计算无符号 8 位 a×b，输出 16 位 product。接口含低有效异步复位 rst_n、启动 start、忙信号 busy 和完成脉冲 done。只在空闲时接受 start；每笔运算需要 8 个计算时钟沿。运算过程中 product 保持上一笔结果，最后一拍更新为新乘积。

## RTL 电路说明

RTL 位于 rtl/seq_multiplier8.v。

- shifted_a 保存被乘数并左移；shifted_b 保存乘数并右移。
- 每拍查看 shifted_b[0]：最低位为 1 时，将 shifted_a 加到 partial_sum；为 0 时加 0。
- 复用一个 16 位加法器进行部分积累加。迭代计数器达到第 8 拍时，将 next_sum 写入 product、清 busy，并产生一个周期的 done。
- 启动沿锁存 a/b，初始化部分和与移位寄存器。忙时输入变化或 start 脉冲不会改变当前运算。
- rst_n 拉低会异步清除乘积、部分和、移位寄存器、计数器和握手状态。

## TB 与验证命令

tb/tb_seq_multiplier8.sv 使用乘法运算作为独立参考结果，覆盖 0、边界值、最大值、定向值和 50 组伪随机数；还检查 8 拍延迟、忙时输入变化和 start、product 保持、done 单拍脉冲及运算中异步复位。

在本目录运行：

    make test
    make clean

test 使用 VCS，所有生成物位于 build/。tb/tb_seq_multiplier8_gate.sv 仅用于门级 SDF；它需要相符的综合网表、SDF 和工艺库仿真模型，不属于 make test 的行为级验证。

此模块是串行数据通路的乘法练习，报告流程见 [考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
## 本次验证结果

2026-10-28 在 Rocky Linux 8.10 WSL 使用 VCS V-2023.12-SP1 运行 make test：PASS，56 组乘法事务；TB 另检查了运行中异步复位。随后 make clean 已清理 build/.
