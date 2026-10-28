# 19 · 位串行加/减法器（教科书版串行加法器）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[BitSerialAddSub.v](BitSerialAddSub.v) · [BitSerialAddSub_tb.v](BitSerialAddSub_tb.v)
> 复习优先级：★★★ ｜ 对应：和往年题同类：M3 全加器 + 1 个触发器（最小的 FSM） ｜ 上机预计：约 45 分钟

## 一、题目可能怎么出

**可能的题面：**"设计一个串行加法器，两个操作数**逐位**从两根输入线进来（低位在前），和也逐位输出"，或者"加一个控制信号，同时支持加法和减法"。

和 [17](../17_可变位宽串行加法器/17_SerialAdder_讲解.md) 的区别：17 是**并行装载**（A、B 一次给 16 位，内部移位）；这题是**位串行输入**，数据本来就是一位一位来的（比如来自串行接口），电路里**连移位寄存器都不需要**，只有 1 个全加器 + 1 个进位触发器。教科书上的"serial adder"一般指这一种。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位 |
| FIRST | input | 和一个新字的第 0 位（最低位）一起为 1 |
| SUB | input | 0 = 加法，1 = 减法（一个字内保持不变） |
| A, B | input | 当前这一位 |
| S | output | 当前这一位的结果（**Mealy**：当拍就出来） |
| CO | output | 当前这一位的进位输出（减法时 CO=1 表示**没有借位**） |

## 二、电路思路 + 代码逐段讲

**减法怎么变成加法：**A − B = A + (~B) + 1。所以减法时把 B 取反，最低位的进位输入设成 1。

```verilog
wire b_eff = B ^ SUB;                 // SUB=1 时 B 取反
wire c_in  = FIRST ? SUB : carry;     // 新字第 0 位：进位输入 = SUB（加 0 / 减 1）
assign S  = A ^ b_eff ^ c_in;         // 全加器
assign CO = (A & b_eff) | (c_in & (A ^ b_eff));
always @(posedge CLK or negedge NRST)
    if (!NRST) carry <= 0; else carry <= CO;   // 存起来给下一位
```

**逐拍演示：5 − 3，n = 4**（A = 0101，B = 0011，~B = 1100，SUB = 1）

| 拍 | FIRST | A | B | b_eff | c_in | S | CO（存进 carry） |
|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 0 | **1**（=SUB） | 0 | 1 |
| 2 | 0 | 0 | 1 | 0 | 1 | 1 | 0 |
| 3 | 0 | 1 | 0 | 1 | 0 | 0 | 1 |
| 4 | 0 | 0 | 0 | 1 | 1 | 0 | **1** |

S 从低到高读出 0010 = **2** ✔；最后 CO = 1 → 没有借位（5 ≥ 3）。3 − 5 时最后 CO = 0（有借位），结果是补码 1110 = −2。

**看成状态机：**carry 触发器就是状态，只有 2 个状态（进位 0 / 进位 1）。输出 S 取决于状态**和当前输入**，所以是 **Mealy 型**，这是笔试画状态图的经典题：

| 当前状态 | 输入 A B | 输出 S | 下一状态 |
|---|---|---|---|
| C0 | 00 / 01,10 / 11 | 0 / 1 / 0 | C0 / C0 / **C1** |
| C1 | 00 / 01,10 / 11 | 1 / 0 / 1 | **C0** / C1 / C1 |

**FIRST 的作用：**字和字之间可以不留空拍。没有 FIRST 的话，就得在两个字之间加一拍清 carry（或者用同步 CLR）。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 字和字之间**不留空拍**，每个字长度 n 随机 1–16，SUB 随机
- **Mealy 输出的采样时刻**：输入在下降沿给出，**在上升沿之前**（下降沿后 5 ns）读 S 和 CO，因为它们当拍就反映当前输入
- 先测 4 个定向字：5+3、5−3、3−5（有借位）、0xFFFF+1（溢出），再测 116 个随机字
- 期望值：加法 `A + B`，减法 `A + ~B + 1`，取低 n 位；CO 取第 n 位
- 故意把 `c_in` 改成永远用 carry（忘了 FIRST），tb 报 52 个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_BitSerialAddSub`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_BitSerialAddSub` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `BitSerialAddSub` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `BitSerialAddSub` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `BitSerialAddSub.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../BitSerialAddSub.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/BitSerialAddSub.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_BitSerialAddSub.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `BitSerialAddSub`，instance 写 `BitSerialAddSub_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_BitSerialAddSub
cd Test2_BitSerialAddSub
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_BitSerialAddSub/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit BitSerialAddSub.v BitSerialAddSub_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./BitSerialAddSub_tb.v ./BitSerialAddSub.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 120 words, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `BitSerialAddSub_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：FIRST、SUB、A、B、S、CO，再从 U1 拖出 carry。看 FIRST=1 那拍进位输入被换成 SUB（加法 0、减法 1），之后每拍用上一拍存下的 carry。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_BitSerialAddSub/Synthesis
cp ../Behavioral/BitSerialAddSub.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/BitSerialAddSub/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/BitSerialAddSub.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/BitSerialAddSub.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_BitSerialAddSub/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `BitSerialAddSub` → **Schematic View**（截图）

**2.4 在 `design_vision>` 里查结果（答题用，结果截图或记下来）：**

```tcl
report_clock
report_area
report_cell
report_timing -significant_digits 4            ;# 看 slack，要 MET
report_timing -delay_type min -significant_digits 4   ;# hold 路径
report_qor
report_constraint -all_violators
report_power
exit
```

检查产物：

```csh
ls ~/NM6008/Test2_BitSerialAddSub/Synthesis/netlist/      # 要有 Syn_BitSerialAddSub.v  Syn_BitSerialAddSub.sdf  Syn_BitSerialAddSub.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_BitSerialAddSub/rtl
cp ../Synthesis/netlist/Syn_BitSerialAddSub.v ../Synthesis/netlist/Syn_BitSerialAddSub.sdf .
cp ../Behavioral/BitSerialAddSub_tb.v .
ls                      # 要有 Syn_BitSerialAddSub.v  Syn_BitSerialAddSub.sdf  BitSerialAddSub_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./BitSerialAddSub_tb.v ./Syn_BitSerialAddSub.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_BitSerialAddSub.v`（网表）**，不是 `BitSerialAddSub.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 120 words, 0 errors ====`
- S、CO 是 Mealy 输出（组合逻辑），tb 在下降沿给输入、**下降沿后 5 ns（上升沿之前）**采样，门延时只有几十 ps，不受影响。

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_BitSerialAddSub/rtl/PowerAnalysis
grep -n "SEARCH_PATH" common_setup_gf22.tcl     # 相对路径 ../../Library 就不用改
csh
source synopsys_linux_vR_2020_cshrc
vpd2vcd ../inter.vpd inter.vcd
vcd2saif -i ./inter.vcd -o inter.saif
ls -l inter.saif          # 不是 0 字节就对了
gedit pa.tcl &
```

`pa.tcl` 的内容（整段粘贴，覆盖原来的）：

```tcl
read_verilog ../Syn_BitSerialAddSub.v
current_design BitSerialAddSub
link
read_saif -input ./inter.saif -instance BitSerialAddSub_tb/U1
report_saif                          > rpt_saif.txt
report_power                         > rpt_power.txt
report_power -hier                   > rpt_power_hier.txt
report_power -hier -nosplit          > rpt_power_hier_nosplit.txt
report_power -cell                   > rpt_power_cell.txt
exit
```

保存后运行：

```csh
dc_shell-xg-t -f pa.tcl | tee power_run.log
cat rpt_saif.txt
cat rpt_power.txt
```

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `BitSerialAddSub_tb/U1`）
- `link` 报 `Unable to resolve reference` → 库路径不对，回到 `common_setup_gf22.tcl`
- 记下 Internal / Switching / Leakage / Total，和第 2 步的 `report_power` 对比

### 结果记录表（考试时边做边填）

| 项目 | 结果 |
|---|---|
| 行为仿真 | __ errors |
| cell 数 / 面积 | |
| 用了哪些门（report_cell） | |
| 寄存器个数 | |
| setup slack / hold slack | |
| 门级仿真 | __ errors，SDF errors = 0 |
| 功耗：合成估计 / SAIF 反标 | |

## 五、可能被问的问题（附答案）

**Q：串行加法器为什么是 Mealy 型？能改成 Moore 型吗？**
输出 S 由当前状态（carry）和当前输入共同决定。改成 Moore 型需要把"和"也编码进状态（4 个状态：carry × sum），输出晚一拍。

**Q：减法时 CO 的含义？**
CO = 1 表示没有借位（A ≥ B，按 n 位无符号比较），CO = 0 表示有借位。

**Q：和 17 题（并行装载的串行加法器）比，哪个面积小？**
这题小得多：只有 1 个全加器 + 1 个触发器 + 几个门。17 还要 3 个 16 位寄存器和计数器。但这题要求数据本来就是串行来的。

**Q：怎么判断有符号溢出？**
最高位的进位输入和进位输出不同时溢出：V = c_in(最高位) ⊕ CO(最高位)。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：18 移位相加乘法器（8×8 无符号）](../18_移位相加乘法器/18_ShiftAddMul_讲解.md) ｜ [下一题：20 移位相减除法器（恢复余数法，8÷8）](../20_移位相减除法器/20_ShiftSubDiv_讲解.md)
