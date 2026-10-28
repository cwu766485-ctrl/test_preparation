# 05 · Module 4 状态机 + 寄存器输出（消除毛刺）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[StateMachine.v](StateMachine.v) · [StateMachine_tb.v](StateMachine_tb.v)
> 复习优先级：★★★ ｜ 对应：Module 4 选做题（你报告第 5 节已经做过） ｜ 上机预计：约 45 分钟（脚本不用改名）

## 一、题目可能怎么出

**可能的题面：**
- Module 4 原题："S 和 COUT 是组合输出，可能有毛刺。用触发器消除毛刺，验证新电路，比较新增的硬件和功耗代价。"
- 变体：**改状态机规则**（比如 S1 输出 Carry、S2 输出 Sum；增加一个状态 S4；start 改成在 S3 也起作用），然后重新跑整套流程。

> 你的 Module 4 报告第 5 节已经完整做过：面积 +43.6%，功耗 +44.3%（783.4 → 1130.6 nW），多 1 拍延迟。这道题主要是复习 + 应对改规则。

端口和 Module 4 一样：CLK、NRST、start、rst、CIN、A、B → S、COUT。

## 二、电路思路 + 代码逐段讲

**状态图（Module 4 手册 Fig. 3）：**
- S0 ──start──► S1，否则停在 S0
- S1 → S2 → S3 → S1 循环；S1/S2/S3 里只要 rst=1 就回 S0
- S 在 S1、S3 输出全加器的和；COUT 在 S2、S3 输出进位；其他时候为 0

**改动只有一处：输出从 `assign` 变成触发器**

```verilog
output reg S, COUT;                  // 原来是 output wire
wire S_comb, COUT_comb;              // 原来的组合输出，改成内部信号

always @(posedge CLK or negedge NRST)
    if (!NRST) begin state <= S0; S <= 0; COUT <= 0; end
    else begin
        state <= next_state;
        S     <= S_comb;              // 新增的两个触发器
        COUT  <= COUT_comb;
    end
```

- 毛刺发生在组合逻辑内部（A、B、CIN 先后到达），但触发器只在上升沿采样一次，毛刺在采样前已经消失，所以输出干净
- 代价：**2 个 FF + 1 个周期延迟**。延迟是必然的：S 依赖本周期的 A/B/CIN，最早只能在本周期结束时采样
- 模块名、端口名和 Module 4 完全一样，**综合脚本不用改名**

**如果考试改了规则，只需要改两处：**
1. `case (state)` 里的转移（照新状态图抄）
2. `S_comb` / `COUT_comb` 那两行里的状态条件

状态超过 4 个时，状态寄存器改成 3 位：`reg [2:0] state, next_state;`，parameter 也改成 3 位。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 激励表 `ctrl[i] = {start, rst, B, A, CIN}`：第 1、14 拍给 start，第 12、25 拍给 rst，A/B/CIN 用 `(i*5)%8` 遍历 8 种组合（和你 Module 4 的 tb 一样）
- 参考模型：同样的 FSM + 全加器，但输出**也延迟一拍**（`exp_S <= ...`）
- **毛刺监视器**：记录每个上升沿的时间 `t_edge`；S 或 COUT 一变化就看距离上一个上升沿是否超过 2 ns，超过就算一次"沿外变化"
- 最后要多跑一拍，因为最后一组输入的结果晚一拍才出来
- **时钟：**Module 4 的综合周期是 100 ns，所以 tb 里已经写成 `parameter CLK_T = 50;`（半周期 50 → 周期 100）。如果你是从 Module5 复制（周期 20），就改成 `CLK_T = 10`

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_StateMachine`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module4` | `Test2_StateMachine` |
| 模块名 / 脚本名 | `StateMachine` | **不用改**（本题模块名和 Module4 一样） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **100**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_StateMachine.sdf`（已写好） |
| 功耗 `pa.tcl` | `StateMachine` | `StateMachine`，instance 写 `StateMachine_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module4 Test2_StateMachine
cd Test2_StateMachine
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module4 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_StateMachine/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit StateMachine.v StateMachine_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./StateMachine_tb.v ./StateMachine.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 0 errors, 0 off-edge output changes ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `StateMachine_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：S_comb 和 S（从 `U1` 里拖出 S_comb）放一起：S 就是 S_comb 晚一个周期，而且只在上升沿后变化。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_StateMachine/Synthesis
cp ../Behavioral/StateMachine.v sources/
ls sources/ scripts/
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/StateMachine.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **100**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 50;` → 时钟周期 2×50 = 100 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_StateMachine/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `StateMachine` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_StateMachine/Synthesis/netlist/      # 要有 Syn_StateMachine.v  Syn_StateMachine.sdf  Syn_StateMachine.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_StateMachine/rtl
cp ../Synthesis/netlist/Syn_StateMachine.v ../Synthesis/netlist/Syn_StateMachine.sdf .
cp ../Behavioral/StateMachine_tb.v .
ls                      # 要有 Syn_StateMachine.v  Syn_StateMachine.sdf  StateMachine_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./StateMachine_tb.v ./Syn_StateMachine.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_StateMachine.v`（网表）**，不是 `StateMachine.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 0 errors, 0 off-edge output changes ====`
- tb 的 glitch 监视器会统计离上升沿超过 2 ns 的输出变化。门级仿真里应该还是 0。

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_StateMachine/rtl/PowerAnalysis
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
read_verilog ../Syn_StateMachine.v
current_design StateMachine
link
read_saif -input ./inter.saif -instance StateMachine_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `StateMachine_tb/U1`）
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

**Q：为什么组合输出会有毛刺？**
A、B、CIN 和 state 到达门的时间不同（路径长度不同），输出在稳定前可能短暂变成错误值。

**Q：新增的 FF 几乎不翻转，为什么功耗还涨了这么多？**
FF 内部的时钟电路每个周期翻转两次，和数据变不变无关；另外 22 nm 的 FF 漏电大。你的报告里两个新 FF 占了 98% 的功耗增量。

**Q：寄存输出后时钟到输出的延时为什么反而更短？**
原来输出 = clk→Q（state）+ 几级门；现在只有一个 clk→Q。输出更早稳定，只是晚了一个周期。

**Q：除了加寄存器，还有什么办法？**
状态编码直接用输出位（output encoding），让输出就是状态寄存器的某几位；或者用格雷码让每次只变一位。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：04 "101" 序列检测器（Mealy 型）](../04_101序列检测器_Mealy型/04_SeqDet101_Mealy_讲解.md) ｜ [下一题：06 全加器 56 种输入跳变 + 关键延时](../06_全加器56种跳变/06_FullAdder_All56_讲解.md)
