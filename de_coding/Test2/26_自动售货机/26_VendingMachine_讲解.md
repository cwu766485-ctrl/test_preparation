# 26 · 自动售货机（15 分，收 5 分和 10 分硬币，找零）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[VendingMachine.v](VendingMachine.v) · [VendingMachine_tb.v](VendingMachine_tb.v)
> 复习优先级：★☆☆ ｜ 对应：M4 状态机（教科书经典题） ｜ 上机预计：约 40 分钟

## 一、题目可能怎么出

**可能的题面：**"商品 15 分，接受 5 分（nickel）和 10 分（dime）硬币，投够出货，多了找 5 分"。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位 |
| NICKEL | input | 投入 5 分时为 1（一拍） |
| DIME | input | 投入 10 分时为 1（一拍）；和 NICKEL 同时为 1 视为非法，忽略 |
| VEND | output | 出货（一拍） |
| CHANGE | output | 找回一个 5 分（一拍） |

## 二、电路思路 + 代码逐段讲

**状态 = 已经投了多少钱：**S0（0 分）、S5（5 分）、S10（10 分）。到 15 分就出货并回到 S0。

| 当前状态 | 投 5 分 | 投 10 分 |
|---|---|---|
| S0 | → S5 | → S10 |
| S5 | → S10 | → S0，**VEND** |
| S10 | → S0，**VEND** | → S0，**VEND + CHANGE** |

不投币时保持当前状态。

```verilog
VEND <= 0; CHANGE <= 0;                      // 默认：一拍的脉冲
if (NICKEL && !DIME) case (state)
    S0: state <= S5;   S5: state <= S10;
    S10: begin state <= S0; VEND <= 1; end
endcase
else if (DIME && !NICKEL) case (state)
    S0: state <= S10;
    S5: begin state <= S0; VEND <= 1; end
    S10: begin state <= S0; VEND <= 1; CHANGE <= 1; end
endcase
```

- **输出是寄存器**：VEND、CHANGE 在投币后的下一拍出现，没有毛刺。如果写成组合输出 `assign VEND = (state==S10 && NICKEL) || ...`，就是 Mealy 型，当拍出货但可能有毛刺
- **非法输入**（两个同时为 1）要有明确处理，这里是忽略。考试时题目没说的情况，自己定一个合理的规则并在报告里写清楚
- 价格改成 20、加 25 分硬币，就是加状态、改表

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 先测定向序列：5+5+5、10+5、5+10、10+10（找零）、5+5+10（找零）、两个硬币同时（忽略）
- 再测 400 拍随机投币，**可以每拍都投**
- 参考模型用整数记录余额，每拍比较 VEND 和 CHANGE
- 最后做**钱数守恒检查**：投进的钱 = 15 × 出货数 + 5 × 找零数 + 剩余余额
- 故意去掉 10+10 时的找零，tb 报 40 个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_VendingMachine`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_VendingMachine` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `VendingMachine` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `VendingMachine` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `VendingMachine.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../VendingMachine.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/VendingMachine.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_VendingMachine.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `VendingMachine`，instance 写 `VendingMachine_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_VendingMachine
cd Test2_VendingMachine
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_VendingMachine/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit VendingMachine.v VendingMachine_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./VendingMachine_tb.v ./VendingMachine.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 1595 cents in, 93 items, 39 changes, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `VendingMachine_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：NICKEL、DIME、state、VEND、CHANGE。投满 15 分后的下一拍 VEND=1；10+10 时 VEND 和 CHANGE 同时为 1。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_VendingMachine/Synthesis
cp ../Behavioral/VendingMachine.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/VendingMachine/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/VendingMachine.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/VendingMachine.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_VendingMachine/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `VendingMachine` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_VendingMachine/Synthesis/netlist/      # 要有 Syn_VendingMachine.v  Syn_VendingMachine.sdf  Syn_VendingMachine.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_VendingMachine/rtl
cp ../Synthesis/netlist/Syn_VendingMachine.v ../Synthesis/netlist/Syn_VendingMachine.sdf .
cp ../Behavioral/VendingMachine_tb.v .
ls                      # 要有 Syn_VendingMachine.v  Syn_VendingMachine.sdf  VendingMachine_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./VendingMachine_tb.v ./Syn_VendingMachine.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_VendingMachine.v`（网表）**，不是 `VendingMachine.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 1595 cents in, 93 items, 39 changes, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_VendingMachine/rtl/PowerAnalysis
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
read_verilog ../Syn_VendingMachine.v
current_design VendingMachine
link
read_saif -input ./inter.saif -instance VendingMachine_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `VendingMachine_tb/U1`）
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

**Q：画出 Moore 型和 Mealy 型的状态图，各有几个状态？**
Mealy（输出在转移上）：3 个状态 S0/S5/S10。Moore（输出在状态上）：要增加"出货"和"出货 + 找零"状态，共 5 个，输出晚一拍但更干净。本题是"寄存的 Mealy"：3 个状态，输出打一拍。

**Q：3 个状态需要几个触发器？有一个编码没用到，怎么处理？**
2 个触发器。2'b11 没用到，`default: state <= S0` 让它回到安全状态。

**Q：怎么扩展成可以买多件、多个价格？**
状态换成一个余额寄存器 + 加法器 + 比较器（数据通路），控制部分只负责"够不够、找多少"，这就变成"数据通路 + 控制器"的结构了。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：25 交通灯控制器（主路 / 支路 + 车辆传感器）](../25_交通灯控制器/25_TrafficLight_讲解.md)
