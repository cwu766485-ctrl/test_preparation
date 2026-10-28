# 06 · 全加器 56 种输入跳变 + 关键延时

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[FullAdder.v](FullAdder.v) · [FullAdder_tb_all.v](FullAdder_tb_all.v)
> 复习优先级：★★☆ ｜ 对应：Module 3 选做题 B1/B2（你报告里已经做过） ｜ 上机预计：约 20 分钟（不用重新综合）

## 一、题目可能怎么出

**可能的题面（Module 3 选做原题）：**
- B1："写一个 testbench 产生所有可能的输入跳变（共 56 种）。"
- B2："找出全加器的关键延时，以及造成它的输入（当前输入 → 下一个输入）。"
- 变体：换成别的小组合电路（比如 2 选 1 MUX：3 个输入 → 同样 56 种），方法完全一样。

**为什么是 56：**3 个输入有 8 种取值。"跳变" = 从一个值变到**另一个不同的**值：8 × 7 = 56。

> 你的 Module 3 报告结果：S 最慢 **53 ps**（{B A CIN} 001 → 101），COUT 最慢 **39 ps**（000 → 101 和 001 → 101），和 STA 的 54.3 / 40.6 ps 只差 1–2 ps。

## 二、电路思路 + 代码逐段讲

设计文件就是 Module 3 的 `FullAdder.v`，不用改。这题的重点全在 testbench：

```verilog
for (p = 0; p < 8; p = p + 1)            // 当前输入
  for (n = 0; n < 8; n = n + 1)          // 下一个输入
    if (n != p) begin                    // 去掉"没变化"的 8 种 → 56 种
        {B, A, CIN} = p; #10;            // 先稳定在当前输入
        t_in = $realtime; meas = 1;      // 记下跳变时刻，开始测量
        {B, A, CIN} = n; #10;            // 跳变，等输出稳定
        meas = 0;
    end
```

**怎么测延时：**

```verilog
always @(S) if (meas) begin d_s = $realtime - t_in; ns_s = ns_s + 1; end
```

S 每变一次，记下"现在 − 跳变时刻"。最后留下的是**最后一次变化**的时间 = 稳定时间。`ns_s` 数变了几次：

| ns_s | 含义 |
|---|---|
| 0 | 输出没变 |
| 1 | 干净地变了一次 ✔ 算延时 |
| 2 | 变过去又变回来 = **毛刺**，不算 |

只在奇数次变化时更新最大值 `max_s`，同时记下是哪个跳变（`ms_p → ms_n`）。

**为什么必须做门级仿真：**行为仿真里没有门延时，所有延时都是 0。必须用综合后的网表 + SDF。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- `realtime t_in, d_s ...`：实数时间变量，能表示 0.053 ns 这种小数
- 打印时 `d_s*1000`：ns → ps
- 输出写到 `All56.txt`，每行一个跳变，最后两行是最坏情况
- 在**行为仿真**里跑只能检查 "Transitions applied = 56"（延时全是 0.0）；真正的结果看门级仿真

## 四、上机步骤（照着敲就行）

> 这题**不用重新综合**：直接用 Module 3 已经综合好的 `Syn_FullAdder.v` 和 `Syn_FullAdder.sdf`，只换 testbench。
> 完整原理见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 第 0 步：复制 Module 3

```csh
cd ~/NM6008
cp -r Module3 Test2_FullAdder
cd Test2_FullAdder/rtl          # 如果是 RTL（大写）就 cd RTL
ls                              # 要有 Syn_FullAdder.v  Syn_FullAdder.sdf  library.f
```

如果 `ls` 里**没有** `Syn_FullAdder.v` / `.sdf`：先按 [01_Adder4 的第 2 步](../01_四位加法器/01_Adder4_讲解.md) 的方法综合一次 FullAdder（名字不用改），再把 `netlist/` 里的两个文件复制过来。

### 第 1 步：放 testbench、门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_FullAdder/rtl
csh
source synopsys_linux_vP_2019_cshrc
gedit FullAdder_tb_all.v &
```

把本文件夹的 `FullAdder_tb_all.v` 粘贴进去、保存，然后：

```csh
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./FullAdder_tb_all.v ./Syn_FullAdder.v -f ./library.f -o simv_all -l compile_all.log
./simv_all
grep -i -E "sdf|annotat" compile_all.log
cat All56.txt
```

- `-o simv_all`：可执行文件起个新名字，不会覆盖原来 Module 3 的 `simv`
- 终端最后会打印：`Transitions applied = 56`、`Worst S delay = ... ps`、`Worst COUT delay = ... ps`
- **截图 `All56.txt`**（56 行 + 最后的最坏情况两行）
- 想看波形：`./simv_all -gui &`，在最坏的那个跳变附近放大到 ps 级，用两个 cursor 量延时

### 第 2 步（可选）：行为仿真里检查 tb 本身没写错

```csh
cd ~/NM6008/Test2_FullAdder/Behavioral
cp ../rtl/FullAdder_tb_all.v .
vcs -debug +v2k ./FullAdder_tb_all.v ./FullAdder.v -o simv_all
./simv_all                       # 应打印 Transitions applied = 56，延时全是 0.0（行为模型没有延时）
```

### 结果记录表

| 项目 | 结果 |
|---|---|
| 跳变总数 | 56 |
| S 最坏延时 / 对应跳变 {B A CIN} | （报告里：53 ps，001 → 101） |
| COUT 最坏延时 / 对应跳变 | （报告里：39 ps，000 → 101） |
| STA（report_timing）对比 | 54.3 ps / 40.6 ps |
| 有没有毛刺（#chg = 2） | |

## 五、可能被问的问题（附答案）

**Q：为什么 B 单独翻转且 CIN = 1 时 S 最慢？**
B 变化会让 A⊕B 先变，再经过第二个 XOR 到 S，一共两级门；CIN=1 时第二个 XOR 相当于反相器，S 是下降沿，这个单元的下降更慢。只改 CIN 时只经过一级门，所以快。

**Q：仿真得到的最坏延时为什么比 STA 小一点？**
STA 按最坏输入斜率、最坏 timing arc 取上界，所以 STA 是"保证不会超过"的值；仿真只是具体输入下的实际值。

**Q：Module 3 给的测试向量为什么测不到最坏延时？**
给定的向量里只有 CIN 单独变化的情况（一级门路径），没有覆盖 A/B 单独翻转的两级门路径。所以要穷举所有跳变。

**Q：为什么有几行延时显示 0.0 ps？**
多个输入同时变化时，单元模型里的条件延时（state-dependent path delay）匹配不上，仿真器就不加延时。是仿真模型的问题，不影响最坏情况结论。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：05 Module 4 状态机 + 寄存器输出（消除毛刺）](../05_状态机寄存器输出/05_StateMachine_RegOut_讲解.md) ｜ [下一题：07 Module 5 矩阵乘法器：无符号版](../07_无符号矩阵乘法器/07_MatMul_Unsigned_讲解.md)
