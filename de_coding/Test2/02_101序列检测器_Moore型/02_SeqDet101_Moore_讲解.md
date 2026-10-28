# 02 · "101" 序列检测器（Moore 型）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[SeqDet101.v](SeqDet101.v) · [SeqDet101_tb.v](SeqDet101_tb.v)
> 复习优先级：★★★ ｜ 对应：Module 4（状态机） ｜ 上机预计：约 60 分钟

## 一、题目可能怎么出

**可能的题面：**
- "设计一个状态机，检测串行输入 DIN 中的 101 序列，检测到时输出 DET=1（允许重叠）。"
- 变体：检测 110 / 1011 / 0110；不允许重叠；改成 Mealy 型（见 [04_SeqDet101_Mealy](../04_101序列检测器_Mealy型/04_SeqDet101_Mealy_讲解.md)）。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK | input | 时钟，每个上升沿读一位 DIN |
| NRST | input | 异步复位，低有效 |
| DIN | input | 串行输入 |
| DET | output | 检测到 101 后为 1，保持一个周期 |

**"允许重叠"是什么意思：** 输入 `1 0 1 0 1`，前三位是一个 101，后三位（第 3–5 位）也是一个 101，所以 DET 要出现 **2 次**。

## 二、电路思路 + 代码逐段讲

**第一步：画状态图**（考试先在草稿纸上画，代码就是照着抄）

每个状态记住"已经匹配了几位"：

| 状态 | 含义 | DIN=0 去哪 | DIN=1 去哪 | DET |
|---|---|---|---|---|
| S0 | 什么都没匹配 | S0 | S1 | 0 |
| S1 | 收到 "1" | S2 | S1（"11" 仍然有一个 1） | 0 |
| S2 | 收到 "10" | S0（"100" 全废了） | S3 | 0 |
| S3 | 收到 "101" ✔ | S2（末尾 "1"+"0" = "10"） | S1（末尾 "1"） | **1** |

最难的是 S3 之后去哪：**看已经收到的序列末尾，还能当作新 101 的开头用多少位。** 这就是"重叠"。如果题目说**不允许重叠**，S3 收到 0 回 S0、收到 1 回 S1。

**第二步：三段式代码（和 Module 4 一模一样的结构）**

```verilog
// ① 状态寄存器：时序逻辑，用 <=
always @(posedge CLK or negedge NRST)
    if (!NRST) state <= S0;            // 异步复位：NRST 在敏感列表里
    else       state <= next_state;

// ② 次态逻辑：组合逻辑，用 =，必须有 default
always @(state or DIN)
    case (state)
        S0: next_state = DIN ? S1 : S0;
        ...
        default: next_state = S0;
    endcase

// ③ 输出：Moore 型只看 state
assign DET = (state == S3);
```

- `parameter S0 = 2'b00;`：给状态起名字，4 个状态需要 2 位
- `DIN ? S1 : S0`：条件运算符，DIN 为 1 取 S1，否则 S0
- `default`：state 理论上只有 4 种取值，但写上 default 可以保证组合逻辑不会综合出 latch，也是好习惯

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- `reg [N-1:0] stream = 20'b1011_0101_...;`：要发送的比特流，从最高位开始发
- **在下降沿改 DIN（`@(negedge CLK)`），在上升沿后 2 ns 检查 DET**：输入离采样沿有半个周期，行为仿真和门级仿真都不会出现竞争
- 参考模型 `hist = {hist[1:0], DIN};`：一个 3 位移位寄存器记住最近 3 位，`hist == 3'b101` 时 DET 就应该是 1。tb 用最笨但绝对正确的方法算答案，再和设计对比
- 最后测异步复位：在两个时钟沿之间拉低 NRST，DET 要立刻变 0
- 时钟：`parameter CLK_T = 10;` 是**半周期**，周期 = 20 ns，要和综合的 CLK_PERIOD = 20 一致

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_SeqDet101`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_SeqDet101` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `SeqDet101` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `SeqDet101` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `SeqDet101.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../SeqDet101.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/SeqDet101.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_SeqDet101.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `SeqDet101`，instance 写 `SeqDet101_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_SeqDet101
cd Test2_SeqDet101
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_SeqDet101/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit SeqDet101.v SeqDet101_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./SeqDet101_tb.v ./SeqDet101.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 6 detections, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `SeqDet101_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：CLK、NRST、DIN、DET，再从 `U1` 里拖出 `state`（只有行为仿真看得到，门级网表里内部名字会变）。DET 应该在收到 1→0→1 之后的那个时钟沿变成 1。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_SeqDet101/Synthesis
cp ../Behavioral/SeqDet101.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/SeqDet101/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/SeqDet101.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/SeqDet101.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_SeqDet101/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `SeqDet101` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_SeqDet101/Synthesis/netlist/      # 要有 Syn_SeqDet101.v  Syn_SeqDet101.sdf  Syn_SeqDet101.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_SeqDet101/rtl
cp ../Synthesis/netlist/Syn_SeqDet101.v ../Synthesis/netlist/Syn_SeqDet101.sdf .
cp ../Behavioral/SeqDet101_tb.v .
ls                      # 要有 Syn_SeqDet101.v  Syn_SeqDet101.sdf  SeqDet101_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./SeqDet101_tb.v ./Syn_SeqDet101.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_SeqDet101.v`（网表）**，不是 `SeqDet101.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 6 detections, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_SeqDet101/rtl/PowerAnalysis
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
read_verilog ../Syn_SeqDet101.v
current_design SeqDet101
link
read_saif -input ./inter.saif -instance SeqDet101_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `SeqDet101_tb/U1`）
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

**Q：Moore 和 Mealy 的区别？**
Moore 输出只取决于当前状态；Mealy 输出取决于状态和当前输入。同一功能 Mealy 通常少一个状态、输出早一拍，但输出会跟着输入的毛刺一起抖。

**Q：为什么 next_state 的 always 块用 `=`，state 的用 `<=`？**
组合逻辑用阻塞赋值 `=`，按顺序立即计算；时序逻辑用非阻塞 `<=`，所有寄存器在同一时刻一起更新，不会互相影响。

**Q：敏感列表 `@(state or DIN)` 漏写 DIN 会怎样？**
行为仿真里 DIN 变化时 next_state 不更新，结果出错；综合工具会忽略敏感列表照常综合（并给 warning），于是**仿真和综合结果不一致**。用 `always @(*)` 可以避免。

**Q：4 个状态用几个触发器？换成独热码（one-hot）呢？**
二进制编码 2 个 FF；one-hot 每个状态一个 FF，4 个 FF。one-hot 次态逻辑更简单、速度更快，但 FF 更多。

**Q：异步复位和同步复位的区别？**
异步复位写在敏感列表里（`negedge NRST`），不用等时钟就生效；同步复位只在时钟沿生效。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：01 4 位行波进位加法器（Adder4）](../01_四位加法器/01_Adder4_讲解.md) ｜ [下一题：03 4 位计数器（异步复位 + 同步清零 + 使能）](../03_四位计数器/03_Counter4_讲解.md)
