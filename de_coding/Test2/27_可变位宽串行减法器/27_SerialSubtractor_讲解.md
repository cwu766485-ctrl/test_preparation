# 27 · n 位串行减法器（自制变题练习，不是往年真题）

> 参考 [17 串行加法器](../17_可变位宽串行加法器/17_SerialAdder_讲解.md) 的输入方式：一次装入 A、B，内部每拍处理一位。文件：[SerialSubtractor.v](SerialSubtractor.v) · [SerialSubtractor_tb.v](SerialSubtractor_tb.v) · [InputVector.txt](InputVector.txt)。

## 一、假设题面与接口

计算低 N 位的**无符号** `A - B`。N=1..16；本练习约定 N=0 或 >16 按 16 处理。`START` 只在空闲时接受，同时锁存 A、B、N；忙时忽略新的 START。随后从最低位到最高位，每个时钟沿计算一位。最后一位计算完成时 `DONE=1`，只保持一个时钟周期，`DIFF` 和 `BOUT` 此时有效。

| 端口 | 作用 |
|---|---|
| `CLK`, `NRST` | 时钟；低有效异步复位 |
| `START` | 启动，空闲时有效 |
| `A[15:0]`, `B[15:0]` | 两个操作数，只有低 N 位参与 |
| `N[4:0]` | 位数；5 位才能表示 16 |
| `DIFF[15:0]` | 低 N 位差，结果靠低位放，高位清零 |
| `BOUT` | **1 表示发生借位**，即 `A_low < B_low` |
| `DONE` | 结果有效时高一个周期 |

注意：19 题使用二补数加法的 `CO`，其中 **CO=1 表示没有借位**。本题的 `BOUT` 是借位，因此意义相反。如果考卷给不同定义，以题面为准。

## 二、每拍怎么算

一个 1 位减法器重复使用 N 次。把 `A`、`B` 放入两个右移寄存器，每拍处理各自的最低位；借位用一个触发器传到下一拍：

```verilog
wire d_bit = a_sh[0] ^ b_sh[0] ^ borrow;
wire borrow_next = (~a_sh[0] & b_sh[0]) |
                   (borrow & ~(a_sh[0] ^ b_sh[0]));
```

例如 N=4、`5 - 3`：`0101 - 0011 = 0010`。从低位到高位处理，四个差位依次是 `0,1,0,0`，分别写入 `DIFF[0]` 到 `DIFF[3]`；最终 `BOUT=0`。反过来 `3 - 5` 得到低 4 位 `1110`、`BOUT=1`。这表示模 16 的结果与一次借位，不是把输出直接当有符号整数。

时序口径：`START` 所在上升沿装载；其后第 1 到第 N 个上升沿处理第 0 到第 N−1 位；**第 N 个运算沿后** `DONE` 拉高。下一个上升沿 `DONE` 归零。它与 17 题同样属于“先装载，再逐位运算”的结构。

## 三、InputVector 与 testbench

`InputVector.txt` 每行格式为 `NN_AAAA_BBBB`，均为十六进制；例如 `04_0005_0003` 是 N=4、A=5、B=3。`10` 是十六进制的 16。文件有 20 组定向用例，覆盖无借位、有借位、跨位借位、N=1、N=16、高位被忽略和本练习的非法 N 约定。

Testbench 用 `$readmemh` 读这 20 行，再对 N=1..16 各测 8 组随机数，共 **148 组**。它用独立的算式算期望值：

```verilog
mask = 低 N 位全 1;
expected_diff = ((A & mask) - (B & mask)) & mask;
expected_borrow = ((A & mask) < (B & mask));
```

测试还会在启动后改动外部 A/B/N、忙时再拉高 START，检查内部锁存和忙时忽略；检查 `DONE` 出现的运算拍数及单拍脉冲。失败会打印 `FAIL`，详情写入 `Check.txt`。

## 四、练习及考场改动

在这台 Mac 上，用已安装的 Icarus Verilog 在本目录运行：

```sh
iverilog -g2012 -s SerialSubtractor_tb -o simv SerialSubtractor_tb.v SerialSubtractor.v
vvp ./simv
```

在机房 VCS 环境配置好后，也可以在本目录运行：

```sh
vcs -debug +v2k +define+VCS SerialSubtractor_tb.v SerialSubtractor.v -l compile_beh.log
./simv
```

应看到 `==== DONE: 148 subtractions, 0 errors ====`。`InputVector.txt` 必须放在运行 `./simv` 时的当前目录。若复制到课程工程，行为仿真、门级仿真工作目录都要带这份文件；tb 中实例名保持 `U1`，门级 SDF 文件名按综合输出修改。

综合时，顶层名是 `SerialSubtractor`；源文件是 `SerialSubtractor.v`；testbench 不参与综合。沿用 17 题的综合流程时，修改 `ReadVerilogFiles.tcl`、顶层设计脚本、`run_topdown.tcl`、SDF 路径和功耗脚本里的名称，并检查门报告确实映射到课程工艺库。

**此题是自制练习模板。**考试如果改变复位极性、端口名、位宽、借位定义、`DONE` 时间或输入形式，先按题面修改 RTL 和期望值，再运行测试。自动流程脚本尚未在真实机房完整验证，考前要用课程工具实测。

当前这套 RTL、tb 和向量固定按最大位宽 **16** 编写；虽然模块保留了与 17 题一致的 `W` 参数，但若题目要求其他最大位宽，必须一起调整 `N`/计数器宽度、向量格式与 testbench，不能只覆盖 `W`。
