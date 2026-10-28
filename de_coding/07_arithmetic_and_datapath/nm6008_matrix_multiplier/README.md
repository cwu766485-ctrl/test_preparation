# NM6008 Module 5 有符号矩阵乘法器

本例实现课程手册中的两项有符号点积：[A1 A0] × [B1 B0]ᵀ = A1×B1 + A0×B0。单条有符号 8 位 A、B 总线每周期输入一对操作数。START 启动连续数据流；OUT_STROBE 标记有效的 17 位有符号结果。

## RTL 与测试平台

- MatrixMultiplier.v：低有效异步复位；IDLE/FIRST/SECOND 控制器；寄存一个 16 位有符号乘积，将其符号扩展后累加到 17 位累加器，并输出一个周期的结果有效脉冲。三个控制阶段分别对应手册中的 EN1（寄存乘积）、EN2（累加）和 EN3（发布结果）。
- MatrixMultiplier_tb.sv：从 InputVector.txt 读取有符号操作数，按顺序驱动两组输入，并检查正数、负数、零值、全范围边界、脉冲宽度和复位。
- InputVector.txt：每行按 A1 B1 A0 B0 排列，使用十进制有符号数，范围为 -128 到 127。

## 考试命令

在已经配置 VCS 的 Linux/WSL 终端运行：

~~~sh
cd de_coding/07_arithmetic_and_datapath/nm6008_matrix_multiplier
make test
make clean
~~~

make test 会在 build/ 中保留 MatrixMultiplier.vcd 和日志，供 DVE 查看或报告截图使用。运行 make gui 可打开 DVE；把 CLK、NRST、START、A、B、dut.state、dut.product_q、OUT 和 OUT_STROBE 加入波形窗口。

报告可包含波形、RTL 说明、原理图、映射单元和时序报告、门级仿真，以及 Module 6 布局交付物。具体步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。Module 6 Innovus 依赖 PDK；需使用课程提供的 GF22 IO wrapper、LEF/lib、pad 文件、.globals、.io 和实验室环境。不可把其他工艺库的 floorplan 尺寸或 pad 坐标照搬过来。