# 06 · 进阶主题与系统

本目录包含仲裁器、时钟分频器、CRC-8、LFSR、七段数码管扫描、正弦查找表和 UART 接收器。每个主题子目录都提供 RTL/TB 速查说明和 VCS 命令。

在主题目录中运行 make test 和 make clean。报告流程见[考试报告流程](../tools/EXAM_REPORT_GUIDE.md)。
## NM6008 Mock 示例

- [rr_arbiter4_hold](arbiter/rr_arbiter4_hold/README.md)：轮询指针选择请求；ready 低时寄存并保持授权，接受传输后轮转优先级。
- [packet_xor_check](packet_xor_check/README.md)：帧状态控制按字节更新 XOR 和饱和长度；这是 XOR 校验，不是 CRC-8。
