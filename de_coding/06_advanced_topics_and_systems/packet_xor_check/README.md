# Mock7：带帧边界的 XOR 校验器

## 题目与接口

顶层模块 packet_xor_check 接收 8 位数据流。in_valid 标记本周期数据有效，in_start 标记一帧首字节，in_last 标记一帧末字节。每帧输出字节 XOR 校验和 checksum、长度 length、溢出标志 overflow，以及单周期完成脉冲 packet_done。默认 MAX_LEN=8。

## RTL 电路说明

RTL 位于 rtl/packet_xor_check.v。

- 只有 in_valid=1 时才处理输入；valid=0 的空拍不改变帧状态。
- 有效的 in_start 开始一帧并将 running_xor 初始化为首字节、count 初始化为 1。若旧帧尚未结束，新 start 会放弃旧帧并重开。
- 活动帧中每个有效数据字节都与 running_xor 异或，count 递增到 MAX_LEN+1 后饱和。
- 有效的 in_last 结束当前帧：packet_done 拉高一个周期，checksum 锁存最终 XOR，length 锁存饱和长度；长度超过 MAX_LEN 时 overflow 置位。
- 首尾同拍（in_start=in_last=1）表示单字节帧。没有先前 start 的数据字节会被忽略。
- rst_n 为低有效异步复位。校验算法是按字节 XOR，不是 CRC-8。

## TB 与验证命令

tb/tb_packet_xor_check.sv 使用参考模型逐周期比较 done、checksum、length 和 overflow，覆盖无 start 的无效数据、单字节帧、多字节帧、空拍、超长帧饱和、未结束帧被新 start 放弃、随机帧和复位。

在本目录运行：

    make test
    make clean

test 用 VCS 运行行为级 TB，生成物放在 build/。tb/tb_packet_xor_check_gate.sv 是门级 SDF 包装入口，需要匹配的网表、SDF 和工艺库模型。
## 本次验证结果

2026-10-28 在 Rocky Linux 8.10 WSL 使用 VCS V-2023.12-SP1 运行 make test：PASS，382 次 done、checksum、length 和 overflow 检查。随后 make clean 已清理 build/.
