# Test 2 缺项练习：考试时用 VCS 运行

这 14 个练习已补上 Verilog RTL、自检 testbench 和普通名称的 `Makefile`。每个练习目录也有单独的 `README.md`。

## 考试时的指令

进入某个练习目录后，编译并运行：

```sh
make
```

看到 `PASS:` 表示 testbench 自检通过。清除 VCS 编译中间文件和仿真程序：

```sh
make clean
```

例如运行 Moore 型 101 检测器：

```sh
cd de_coding/02_sequential_logic/sequence_101_moore
make
make clean
```

如果机房终端还没有加载 Synopsys 工具环境，先按机房说明执行环境初始化命令，再运行 `make`。不需要写 `make -f ...`；每个练习目录中的文件名就是 `Makefile`。

## 练习目录

- `02_sequential_logic/sequence_101_moore` — Moore 型 101 序列检测器
- `05_fsm_and_protocols/state_machine_regout` — 状态机寄存器输出
- `07_arithmetic_and_datapath/dot_product3` — 三项点积
- `07_arithmetic_and_datapath/code_debug` — 代码改错示例，含错误版和修正版
- `07_arithmetic_and_datapath/serial_adder` — 可变位宽串行加法器
- `07_arithmetic_and_datapath/bit_serial_add_sub` — 位串行加减法器
- `07_arithmetic_and_datapath/serial_comparator` — 位串行比较器
- `07_arithmetic_and_datapath/matvec_2x2` — 二乘二矩阵乘向量
- `07_arithmetic_and_datapath/sum_average` — 求和与平均值
- `07_arithmetic_and_datapath/max_min_index` — 最大最小值与位置
- `05_fsm_and_protocols/vending_machine` — 自动售货机
- `07_arithmetic_and_datapath/serial_subtractor` — 可变位宽串行减法器
- `07_arithmetic_and_datapath/modular_serial_adder` — 模块化十六位串行加法器
- `07_arithmetic_and_datapath/serial_adder_8_sync_reset` — 八位同步复位串行加法器
