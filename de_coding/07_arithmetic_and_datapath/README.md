# 07 · 算术与数据通路

本篇集中整理加法器、减法器、乘法器、除法器、移位器和 ALU。

## 目录结构

```text
07_arithmetic_and_datapath/
├── adders/
│   ├── half_adder/
│   ├── full_adder/
│   ├── ripple_carry_adder/
│   ├── carry_lookahead_adder/
│   ├── carry_select_adder/
│   └── prefix_adder/
├── subtractors/
│   ├── subtractor/
│   ├── add_sub_unit/
│   └── saturating_subtractor/
├── multipliers/
│   ├── shift_add_multiplier/
│   ├── array_multiplier/
│   ├── booth_multiplier/
│   ├── wallace_multiplier/
│   ├── pipelined_multiplier/
│   └── matrix_multiplier/
├── dividers/
│   ├── restoring_divider/
│   ├── non_restoring_divider/
│   ├── radix4_divider/
│   └── pipelined_divider/
├── shifters/
│   ├── logical_shifter/
│   ├── arithmetic_shifter/
│   ├── barrel_shifter/
│   ├── rotate_shifter/
│   └── funnel_shifter/
└── alu/
    ├── simple_alu/
    └── pipelined_alu/
```

每个 `.v` 文件开头都说明了该实现的优势、劣势和适用场景。

乘法器的结构实现如下：`array_multiplier` 生成部分积并使用规则全加器阵列累加；`booth_multiplier` 使用 Radix-2 Booth 重编码处理有符号乘数；`wallace_multiplier` 使用 carry-save 压缩树和末级加法器；`pipelined_multiplier` 先寄存部分积，再用平衡加法树寄存结果，每周期可接收一个输入。它们是便于学习和综合的 RTL 结构，实际面积与时序仍取决于综合工具、位宽和目标工艺库。

除法器均为无符号实现：`restoring_divider` 每周期产生一位商；`non_restoring_divider` 使用带符号部分余数逐位迭代；`radix4_divider` 每周期选择两位商；`pipelined_divider` 将逐位恢复除法展开为 WIDTH 级流水线。除数为零时，这些模块约定商为全 1、余数为被除数，并置位 `div_zero`。

`matrix_multiplier` 使用一个共享的有符号乘加 datapath，逐项计算两个 N×N 矩阵的乘积。矩阵按行优先打包，每个元素占 WIDTH 位；结果元素占 ACC_WIDTH 位。空闲时将 start 拉高一个周期即可启动，输入会在启动时锁存。模块每周期完成一次乘加，计算 N^3 个乘积后拉高一周期 done；此时 matrix_c 为完整结果。
