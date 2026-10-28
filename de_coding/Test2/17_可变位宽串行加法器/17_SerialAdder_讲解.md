# 17 · n 位串行加法器（可变 n，往年 Test 2 原题）

> **机房照做版：**文件复制、改名和四阶段核对请先看 [鼠标复制版操作页](../00_机房四阶段_鼠标复制版.md)。本页后面的终端 `cp` 是等价的旧写法；你在机房直接用文件管理器 Ctrl+C/Ctrl+V。只清理旧结果时按用户规则使用 `/usr/bin/trash`，不要执行旧笔记中的直接删除命令。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[SerialAdder.v](SerialAdder.v) · [SerialAdder_tb.v](SerialAdder_tb.v)
> 复习优先级：★★★ ｜ 对应：往年 Test 2 原题：M3 全加器 + M4 状态机 + M5 数据通路 ｜ 上机预计：约 90 分钟（要从空白写）

## 一、题目可能怎么出

**往年题目（2025 年学长的 Test 2 报告）：**"n-bit Serial Adder"。用**一个 1 位全加器**反复运算，FSM（IDLE、CALC）加计数器控制，n 个时钟算完 n 位加法；位数 n 由输入决定，最大 16 位。学长报告交了：波形、综合的门报告、电路图、文字解释、代码。

**这就是 Test 1 的套路：**Test 1 用 M1/M2 的反相器和 NAND 搭 XOR 和半加器；Test 2 用 M3 的全加器 + M4 的状态机 + M5 的数据通路，拼成串行加法器。

**本题规格：**

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟；异步复位，低有效 |
| START | input | 1 | IDLE 时为 1：锁存 A、B、N，开始计算（忙时忽略） |
| A, B | input | 16 | 两个加数，只加低 N 位 |
| N | input | **5** | 位数 1–16（**必须 5 位，4 位最大只有 15**）；0 或 >16 按 16 处理 |
| SUM | output | 16 | 结果，**对齐到最低位**：SUM[N−1:0] 是和，高位为 0 |
| COUT | output | 1 | 第 N−1 位的进位 |
| DONE | output | 1 | 结果有效时高一拍 |

时序：START 那个沿装载 → 接下来 N 个沿依次算第 0 … N−1 位 → 再下一拍 DONE = 1。共 **N+1** 个周期。

> 如果考试题面给的端口名、复位极性不一样（学长那题是 `rst` 高有效），**按题面改**，思路完全一样。

## 二、电路思路 + 代码逐段讲

**先画"每拍做什么"（考场上第一件事）：**以 5 + 3、N = 4 为例（0101 + 0011）：

| 时钟沿 | 状态 | 这拍加第几位 | a_sh[0] | b_sh[0] | carry(进) | 和位 | 进位(出) | SUM 写成 |
|---|---|---|---|---|---|---|---|---|
| 0 | IDLE→RUN | 装载 A、B，carry=0，SUM=0 | | | | | | 0000 |
| 1 | RUN | 第 0 位 | 1 | 1 | 0 | 0 | 1 | 0000 |
| 2 | RUN | 第 1 位 | 0 | 1 | 1 | 0 | 1 | 0000 |
| 3 | RUN | 第 2 位 | 1 | 0 | 1 | 0 | 1 | 0000 |
| 4 | RUN | 第 3 位（最后一位） | 0 | 0 | 1 | 1 | 0 | **1000** = 8，COUT=0，DONE←1 |

**结构：**

```
   A ─► [a_sh 右移寄存器] ─a_sh[0]─┐
                                   ├─► [1 位全加器] ─s_bit─► SUM[cnt]
   B ─► [b_sh 右移寄存器] ─b_sh[0]─┤            │
                         ┌─────────┘            c_bit
                         └── [carry 触发器] ◄────┘
   [FSM IDLE/RUN] + [cnt 计数器 0..N−1] 控制何时结束
```

**代码要点：**

```verilog
// Module 3 的全加器，输入是两个移位寄存器的最低位 + 存起来的进位
wire s_bit = a_sh[0] ^ b_sh[0] ^ carry;
wire c_bit = (a_sh[0] & b_sh[0]) | (carry & (a_sh[0] ^ b_sh[0]));

IDLE: if (START) begin
    a_sh <= A;  b_sh <= B;
    n_reg <= (N == 0 || N > W) ? W : N;   // 非法 N 的保护
    carry <= 0;                           // 第 0 位没有进位输入（漏了会带上一次的进位！）
    cnt <= 0;   SUM <= 0;                 // 高位清零
    state <= RUN;
end
RUN: begin
    SUM[cnt] <= s_bit;                    // 和位直接写到自己的位置 → 自然对齐低位
    carry    <= c_bit;                    // 进位存到下一拍
    a_sh <= a_sh >> 1;  b_sh <= b_sh >> 1;// 下一位移到第 0 位
    if (cnt == n_reg - 1) begin COUT <= c_bit; DONE <= 1; state <= IDLE; end
    else cnt <= cnt + 1;
end
```

- **`SUM[cnt] <= s_bit`**：下标是变量，综合成一个"译码器 + 每位带使能的触发器"：cnt 等于几，就只更新那一位。这是解决"结果对齐"最简单的办法
- **`DONE <= 1'b0` 写在 case 前面当默认值**，最后一位那拍再写 1 → DONE 自动只高一拍
- **N 用 5 位**：4 位最大 15，表示不了 16
- **START 只在 IDLE 里被看**：计算过程中再来 START 不会打断（tb 专门测了这一点）
- 全加器写成 `assign {c_bit, s_bit} = a_sh[0] + b_sh[0] + carry;` 也可以，结果一样

**另一种对齐方法（学长用的那种移位，改对的写法）：**和位从 MSB 移进 `s_sh <= {s_bit, s_sh[W-1:1]}`。N 拍后和在 `s_sh[W-1 : W-N]`，最后要再右移 `W-N` 位：`SUM <= s_sh >> (W - n_reg)`。这样会多出一个可变移位器（面积更大），所以本题用 `SUM[cnt]` 的写法。

---

### 改错：学长代码的 3 个问题（报告第 1 页他自己写了"限时内没能完成波形仿真和调试"）

> 我把他的代码原样仿真过：**5 + 3、n = 4 输出 32768（0x8000），不是 8**。

| # | 学长写法 | 问题 | 改法 |
|---|---|---|---|
| 1 | `input [3:0] n_in` 却说"最多 16 位" | 4 位最大 15，**表示不了 16**；计数器 `count` 也是 4 位 | N 和 cnt 用 5 位 |
| 2 | `a_reg <= {sum_bit, a_reg[MAX_WIDTH-1:1]}`，结束时 `sum_out <= a_reg` | 和位从最高位（第 15 位）移进去。n = 4 时 4 个和位落在 `a_reg[15:12]`，低位是 A 没用到的高位移下来的 → **结果没对齐**。5+3 的 1000 跑到了第 15–12 位，就是 0x8000 | `SUM[cnt] <= s_bit`，或者最后右移 `16 − n` 位 |
| 3 | tb 里 `@(posedge clk); start = 1; a_in = ...` | 在**上升沿**改输入，和 DUT 采样同一时刻，竞争 | 在 `@(negedge clk)` 改输入 |

另外：他报告里的"门报告"是 **GTECH 单元**（`GTECH_ADD_AB`、`**SEQGEN**`），说明没有映射到 GF22 工艺库，综合没真正完成；他的 tb 也只测了一组数据，而且没有自动比对，只是 `$display` 打印。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 用一个 **task `run_add(a, b, n)`** 封装"给输入 → 等 DONE → 比较"，测试用例写成一行一个调用，考场上加例子很快
- 期望值直接算：`mask = 2^n − 1`，`full = (A & mask) + (B & mask)`，`SUM = full & mask`，`COUT = full[n]`
- 先测定向用例：5+3（学长原题）、有进位的 9+8、n=16 的 0xFFFF+1、n=1、**高位必须被忽略**的 0xABCD+0x1234（n=8）
- 再对 **n = 1 到 16 每个都测 8 组随机数**，共 134 组
- 额外检查：
  - DONE 必须正好在 START 后第 **n+1** 个时钟出现
  - START 之后马上把 A、B 改成别的值：设计必须用自己锁存的那份
  - 计算中途再给一次 START：必须被忽略
- 我用两种故意写错的版本试过：学长那种 MSB 移入 → 116 个 FAIL；START 时不清 carry → 71 个 FAIL。说明 tb 能抓到这两类错

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 以下终端命令使用你现有的 `~/NM6008/Test2_Practice`；如果另建工程或考试时老师指定目录，就相应换路径。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 使用哪个工程 | `Module5` 原件 | 已有的 `Test2_Practice` 副本 |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `SerialAdder` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `SerialAdder` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `SerialAdder.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../SerialAdder.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/SerialAdder.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_SerialAdder.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `SerialAdder`，instance 写 `SerialAdder_tb/U1` |

### 第 0 步：建练习文件夹（文件管理器）

你现在已有 `~/NM6008/Test2_Practice`，**不用再复制工程**。若要另建一份：在 Linux 文件管理器进入 `~/NM6008`，选中整个 `Module5` 文件夹 → Ctrl+C → Ctrl+V → 把新副本重命名为 `Test2_SerialAdder`；打开副本确认有 `Behavioral/`、`Library/`、`Synthesis/`、`rtl/`。

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧运行结果不清理也能重新练习，但要看新结果的修改时间。若确实要清理，先关工具、确认是练习副本；只能用 `/usr/bin/trash` 移入废纸篓。若命令不存在或失败就停止清理。**保留** `Synthesis/netlist/`、`logs/`、`ddc/` 和 `rtl/PowerAnalysis/` 等目录本身。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_Practice/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit SerialAdder.v SerialAdder_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./SerialAdder_tb.v ./SerialAdder.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 134 additions, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `SerialAdder_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：START、N、cnt、a_sh、b_sh、carry、SUM（Hex）、COUT、DONE。看每个时钟沿 a_sh/b_sh 右移一位、SUM 从低位往高位一位一位填上，cnt 到 N−1 后下一拍 DONE=1。

### 第 2 步：综合（T2）

**2.1 用文件管理器放 RTL、改脚本名字：**在两个窗口分别打开 `Behavioral/` 和 `Synthesis/sources/`，把 `SerialAdder.v` 从前者 Ctrl+C/Ctrl+V 到后者；不要复制 tb。打开 `Synthesis/scripts/`：把旧顶层 Tcl 重命名为 `SerialAdder.tcl`，用 gedit 修改 `ReadVerilogFiles.tcl`、`SerialAdder.tcl`、`run_topdown.tcl` 中的设计名。具体点击顺序见[鼠标复制版操作页](../00_机房四阶段_鼠标复制版.md)。

`cat` 出来应该是：`read_verilog ./sources/SerialAdder.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_Practice/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `SerialAdder` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_Practice/Synthesis/netlist/      # 要有 Syn_SerialAdder.v  Syn_SerialAdder.sdf；.sdc 可选
```

> [!note] 综合后要检查两件事
> 1. `report_cell` 里应该是 GF22 的单元名（`HDBSLT20_...`），**不能是 `GTECH_...` 或 `**SEQGEN**`**。学长报告里的门报告就是 GTECH，说明综合没真正完成（只读入、没 compile，或者 link 失败）。
> 2. 寄存器个数大约是：a_sh 16 + b_sh 16 + SUM 16 + carry 1 + COUT 1 + DONE 1 + cnt 5 + n_reg 5 + state 1 ≈ 62 个。实际数字以 `report_qor` 为准，工具可能会优化掉恒定的位。

### 第 3 步：门级仿真（终端 T3）

在文件管理器中，从 `Synthesis/netlist/` 同时选中 `Syn_SerialAdder.v/.sdf`，复制到 `rtl/`；再从 `Behavioral/` 复制 `SerialAdder_tb.v` 到 `rtl/`。确认 `rtl/` 还留有 `library.f`。然后在 `rtl/` 打开终端：

```csh
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./SerialAdder_tb.v ./Syn_SerialAdder.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_SerialAdder.v`（网表）**，不是 `SerialAdder.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 134 additions, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_Practice/rtl/PowerAnalysis
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
read_verilog ../Syn_SerialAdder.v
current_design SerialAdder
link
read_saif -input ./inter.saif -instance SerialAdder_tb/U1
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

- `rpt_saif.txt` **只有 `pa.tcl` 中执行了 `report_saif > rpt_saif.txt` 才会生成**。看活动映射和未匹配警告；不到 100% 不一定是实例路径错，还要核对 VPD 是否记录 DUT、网表是否对应以及测试覆盖范围。
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

**Q：串行加法器和并行（行波进位）加法器比较？**
串行：只用 1 个全加器 + 少量寄存器，组合逻辑面积很小；但 n 位要 n 个周期，吞吐率低。并行：n 个全加器，一个周期出结果（组合延时随位数增加）。典型的**面积 vs 速度**权衡。不过串行版要用好几个 16 位寄存器，总面积不一定小，要看 `report_area`。

**Q：这个电路的关键路径在哪？最高频率由什么决定？**
全加器很短，关键路径大概是 cnt 比较（`cnt == n_reg − 1`）→ 状态/DONE 逻辑，或者 `SUM[cnt]` 的译码使能。看 `report_timing`。

**Q：为什么 carry 要在 START 时清零？**
第 0 位没有进位输入。不清零的话，会把上一次加法最后的进位带进来（tb 的第二个故意出错版本就是这个）。

**Q：N 为什么要用 5 位？**
要表示 1–16，16 = 10000₂ 需要 5 位；4 位最大 15。

**Q：怎么改成串行减法器？**
A − B = A + ~B + 1：B 的每一位取反，carry 初值设成 1。

**Q：Moore 还是 Mealy？**
状态机本身只有 IDLE/RUN 两个状态；所有输出（SUM、COUT、DONE）都是寄存器输出，在时钟沿后才变，所以没有毛刺。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：16 改错题](../16_代码改错/16_Debug_讲解.md) ｜ [下一题：18 移位相加乘法器（8×8 无符号）](../18_移位相加乘法器/18_ShiftAddMul_讲解.md)
