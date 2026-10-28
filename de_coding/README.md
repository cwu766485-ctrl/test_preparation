# 数字芯片 RTL 练习目录

de_coding 按七类主题组织，另含 Test2 考试型练习和共用 VCS 工具。目录结构、主题索引、搜索方式和仿真入口见 [MAP.md](MAP.md)。

NM6008 报告流程（行为仿真波形、Module 3 Design Vision 综合、门级仿真，以及依赖 PDK 的 Module 6 Innovus 步骤）见[考试报告流程](tools/EXAM_REPORT_GUIDE.md)。NM6008 Secret Code 数字发生器题目的实现位于 [assignment/README.md](07_arithmetic_and_datapath/secretcode/assignment/README.md)。

## 目录主题

| 文件夹 | 内容 |
|---|---|
| 01_combinational_logic | 加法器、多路选择器、编码器、比较器、奇偶校验、人口计数、移位器 |
| 02_sequential_logic | 寄存器、计数器、序列检测、边沿检测、分频器 |
| 03_clock_domain_crossing | 同步器、脉冲/握手 CDC、格雷码指针、复位与时钟切换 |
| 04_memory_and_interfaces | RAM、FIFO、串并转换接口 |
| 05_fsm_and_protocols | Moore/Mealy 状态机、握手、PWM、去抖、售货机 |
| 06_advanced_topics_and_systems | 仲裁器、CRC、LFSR、分频器、数码管扫描、查找表、UART |
| 07_arithmetic_and_datapath | 算术运算、串行数据通路、矩阵/点积、乘除法器、ALU |

## 运行与清理

大多数练习目录都提供普通 Makefile。在 Linux/WSL 终端进入对应目录后运行：

~~~sh
cd 02_sequential_logic/counters
make
make clean
~~~

Linux/WSL 环境准备和整库 VCS 回归命令见 [VCS 使用说明](tools/VCS_USAGE.md)。
