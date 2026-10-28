# 04 · "101" 序列检测器（Mealy 型）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[SeqDet101_Mealy.v](SeqDet101_Mealy.v) · [SeqDet101_Mealy_tb.v](SeqDet101_Mealy_tb.v)
> 复习优先级：★★☆ ｜ 对应：Module 4（状态机） ｜ 上机预计：约 60 分钟

## 一、题目可能怎么出

**可能的题面：**
- "用 Mealy 型状态机实现 101 检测"，或者"比较 Moore 和 Mealy 两种实现的状态数、时序、面积"。

端口和 [02 Moore 版](../02_101序列检测器_Moore型/02_SeqDet101_Moore_讲解.md) 完全一样：CLK、NRST、DIN → DET。

## 二、电路思路 + 代码逐段讲

**Mealy 的输出在"边"上，不在"状态"上**，所以少一个状态：

| 状态 | 含义 | DIN=0 | DIN=1 |
|---|---|---|---|
| S0 | 什么都没有 | S0 / DET=0 | S1 / DET=0 |
| S1 | 收到 "1" | S2 / DET=0 | S1 / DET=0 |
| S2 | 收到 "10" | S0 / DET=0 | **S1 / DET=1** ✔ |

在 S2 时 DIN=1，说明 101 凑齐了：**当下**输出 DET=1，然后去 S1（这个 1 可以当下一个 101 的开头 → 重叠）。

```verilog
assign DET = (state == S2) && DIN;   // 状态 AND 当前输入
```

和 Moore 版只差两点：少了 S3；输出式里多了 `DIN`。`default: next_state = S0;` 同时处理了没用到的编码 `2'b11`。

| | Moore（02） | Mealy（04） |
|---|---|---|
| 状态数 | 4 | 3 |
| DET 出现时间 | 最后一个 1 被**时钟采样之后** | 最后一个 1 **出现在 DIN 上时**（早一拍） |
| 输出受输入毛刺影响 | 不受 | 受（DET 直接跟着 DIN） |
| 输出是否对齐时钟沿 | 是 | 否，跟着 DIN 变化 |

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

和 Moore 版最大的区别是**检查时刻**：
- DIN 在下降沿给出，**在下一个上升沿之前**（`#(CLK_T/2)`，下降沿后 5 ns）就检查 DET，因为 Mealy 输出马上就反映当前输入
- 参考模型 `prev2` 只记**之前收到的 2 位**，期望值是 `{prev2, DIN} == 3'b101`
- 上升沿之后才把 DIN 移进 `prev2`（这时这一位才算"收到"）

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_SeqDet101_Mealy`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_SeqDet101_Mealy` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `SeqDet101_Mealy` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `SeqDet101_Mealy` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `SeqDet101_Mealy.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../SeqDet101_Mealy.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/SeqDet101_Mealy.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_SeqDet101_Mealy.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `SeqDet101_Mealy`，instance 写 `SeqDet101_Mealy_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_SeqDet101_Mealy
cd Test2_SeqDet101_Mealy
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_SeqDet101_Mealy/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit SeqDet101_Mealy.v SeqDet101_Mealy_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./SeqDet101_Mealy_tb.v ./SeqDet101_Mealy.v -l compile_beh.log
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

DVE：左边点 `SeqDet101_Mealy_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：把这题和 [02 Moore 版](../02_101序列检测器_Moore型/02_SeqDet101_Moore_讲解.md) 的波形放一起截图：同样的输入，Mealy 的 DET 在最后一个 1 出现的**同一个周期**就变高，Moore 晚一拍。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_SeqDet101_Mealy/Synthesis
cp ../Behavioral/SeqDet101_Mealy.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/SeqDet101_Mealy/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/SeqDet101_Mealy.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/SeqDet101_Mealy.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_SeqDet101_Mealy/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `SeqDet101_Mealy` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_SeqDet101_Mealy/Synthesis/netlist/      # 要有 Syn_SeqDet101_Mealy.v  Syn_SeqDet101_Mealy.sdf  Syn_SeqDet101_Mealy.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_SeqDet101_Mealy/rtl
cp ../Synthesis/netlist/Syn_SeqDet101_Mealy.v ../Synthesis/netlist/Syn_SeqDet101_Mealy.sdf .
cp ../Behavioral/SeqDet101_Mealy_tb.v .
ls                      # 要有 Syn_SeqDet101_Mealy.v  Syn_SeqDet101_Mealy.sdf  SeqDet101_Mealy_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./SeqDet101_Mealy_tb.v ./Syn_SeqDet101_Mealy.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_SeqDet101_Mealy.v`（网表）**，不是 `SeqDet101_Mealy.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 6 detections, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_SeqDet101_Mealy/rtl/PowerAnalysis
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
read_verilog ../Syn_SeqDet101_Mealy.v
current_design SeqDet101_Mealy
link
read_saif -input ./inter.saif -instance SeqDet101_Mealy_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `SeqDet101_Mealy_tb/U1`）
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

**Q：同一个功能，Mealy 为什么能少一个状态？**
Moore 必须用一个专门的状态表示"已检测到"；Mealy 把"检测到"放在转移条件上（S2 且 DIN=1），不需要额外状态。

**Q：Mealy 输出怎么消除毛刺？**
把输出再寄存一拍（变成"寄存的 Mealy"），这样输出时序就和 Moore 一样了。

**Q：综合后两种的面积谁大？**
一般 Mealy 少一个状态，触发器数可能相同（3 个和 4 个状态都需要 2 位），差别主要在组合逻辑，要看 `report_area` 的实际结果。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：03 4 位计数器（异步复位 + 同步清零 + 使能）](../03_四位计数器/03_Counter4_讲解.md) ｜ [下一题：05 Module 4 状态机 + 寄存器输出（消除毛刺）](../05_状态机寄存器输出/05_StateMachine_RegOut_讲解.md)
