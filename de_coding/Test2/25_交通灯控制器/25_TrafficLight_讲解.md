# 25 · 交通灯控制器（主路 / 支路 + 车辆传感器）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[TrafficLight.v](TrafficLight.v) · [TrafficLight_tb.v](TrafficLight_tb.v)
> 复习优先级：★☆☆ ｜ 对应：M4 状态机 + 计数器（定时） ｜ 上机预计：约 50 分钟

## 一、题目可能怎么出

**可能的题面：**"设计一个十字路口的交通灯：主路默认绿灯；支路有车时，主路绿灯至少保持 T 个时钟后切换……"。纯控制类的状态机经典题。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位（复位后主路绿） |
| CAR | input | 支路有车在等时为 1（电平信号） |
| MAIN | output | 主路灯 {红, 黄, 绿}，任何时刻只有一位为 1 |
| SIDE | output | 支路灯 {红, 黄, 绿} |

时间参数（仿真用小数字）：主路最短绿灯 T_MG = 6，黄灯 T_Y = 2，支路绿灯 T_SG = 4。

## 二、电路思路 + 代码逐段讲

**状态图（Moore，4 个状态 + 1 个定时器）：**

```
        ┌────────── timer ≥ T_MG−1 且 CAR=1 ──────────┐
        │                                             ▼
   ┌────┴────┐                                  ┌──────────┐
   │ MG 主绿  │◄── timer = T_Y−1 ──┐            │ MY 主黄   │
   │ 支红     │                    │            │ 支红      │
   └─────────┘               ┌─────┴────┐       └────┬─────┘
                             │ SY 主红   │            │ timer = T_Y−1
                             │ 支黄      │◄─┐         ▼
                             └──────────┘  │   ┌──────────┐
                                timer = T_SG−1 │ SG 主红   │
                                           └───┤ 支绿      │
                                               └──────────┘
```

**三段式写法：**
1. **状态寄存器 + 定时器**：状态改变时 timer 清 0，否则 +1（加到最大值后停住，防止回绕）
2. **次态逻辑**：每个状态"到时间就走"，只有 MG 还要看 CAR
3. **输出逻辑**：只看状态（Moore），一个 case 写出两组灯

```verilog
always @(*) begin
    next_state = state;                               // 默认保持
    case (state)
        MG: if (timer >= T_MG-1 && CAR) next_state = MY;
        MY: if (timer == T_Y-1)         next_state = SG;
        SG: if (timer == T_SG-1)        next_state = SY;
        SY: if (timer == T_Y-1)         next_state = MG;
    endcase
end
```

- **为什么是 `T−1`**：timer 从 0 开始数，0, 1, …, T−1 正好 T 拍
- **安全性**：两条路不能同时不是红灯。4 个状态的输出表里每一行至少有一条路是红灯，tb 每拍都检查这一点
- 真实的交通灯以秒为单位：加一个分频计数器（见 [15 分频器](../15_时钟分频器/15_ClkDiv_讲解.md)）产生 1 Hz 的使能信号，timer 只在使能时 +1
- CAR 是电平信号：如果车在主路绿灯最短时间到之前就走了（CAR 变回 0），不会切换。要"记住"有车来过，可以加一个请求锁存触发器

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- **不比较具体波形，而是检查规则**（每拍都查）：
  1. 每条路正好一盏灯亮
  2. **两条路不能同时不是红灯**（安全性）
  3. 相位顺序必须是 MG → MY → SG → SY → MG
  4. 时长：MY = 2、SG = 4、SY = 2、MG ≥ 6
  5. 只有 CAR = 1 才能离开 MG；最短时间到了、CAR 又是 1，就必须马上离开
- 场景：长时间没车、来一辆车、一直有车（连续循环）、300 拍随机 CAR（含只有 1 拍的脉冲）
- 我试了 3 种故意写错的版本（黄灯多 1 拍、不看 CAR、主支同时绿），都会报 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_TrafficLight`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_TrafficLight` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `TrafficLight` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `TrafficLight` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `TrafficLight.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../TrafficLight.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/TrafficLight.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_TrafficLight.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `TrafficLight`，instance 写 `TrafficLight_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_TrafficLight
cd Test2_TrafficLight
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_TrafficLight/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit TrafficLight.v TrafficLight_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./TrafficLight_tb.v ./TrafficLight.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 408 clocks, 20 side-green phases, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `TrafficLight_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：CAR、MAIN（Binary：R Y G）、SIDE、state、timer。没车时主路一直绿；来车且主路绿灯够 6 拍后，依次黄 2 → 支路绿 4 → 支路黄 2 → 回主路绿。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_TrafficLight/Synthesis
cp ../Behavioral/TrafficLight.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/TrafficLight/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/TrafficLight.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/TrafficLight.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_TrafficLight/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `TrafficLight` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_TrafficLight/Synthesis/netlist/      # 要有 Syn_TrafficLight.v  Syn_TrafficLight.sdf  Syn_TrafficLight.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_TrafficLight/rtl
cp ../Synthesis/netlist/Syn_TrafficLight.v ../Synthesis/netlist/Syn_TrafficLight.sdf .
cp ../Behavioral/TrafficLight_tb.v .
ls                      # 要有 Syn_TrafficLight.v  Syn_TrafficLight.sdf  TrafficLight_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./TrafficLight_tb.v ./Syn_TrafficLight.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_TrafficLight.v`（网表）**，不是 `TrafficLight.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 408 clocks, 20 side-green phases, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_TrafficLight/rtl/PowerAnalysis
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
read_verilog ../Syn_TrafficLight.v
current_design TrafficLight
link
read_saif -input ./inter.saif -instance TrafficLight_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `TrafficLight_tb/U1`）
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

**Q：Moore 还是 Mealy？为什么交通灯适合 Moore？**
Moore：灯只取决于状态。灯必须稳定、不能随输入抖动，所以用 Moore。

**Q：4 个状态用几个触发器？加上定时器呢？**
状态 2 个（二进制编码），定时器 4 个，共 6 个。

**Q：怎么加"行人按钮"？**
增加输入 PED，在 MG 状态下 `CAR || PED` 都能触发切换；或者增加一个"全红 + 行人绿"的状态。

**Q：为什么定时器要饱和而不是回绕？**
MG 可能停留很久（一直没车），4 位计数器回绕后 timer 会变小，`timer >= T_MG−1` 又不成立，来车时要多等一轮。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：24 8 个数找最大值、最小值和最大值位置](../24_最大最小值与位置/24_MaxMin_讲解.md) ｜ [下一题：26 自动售货机（15 分，收 5 分和 10 分硬币，找零）](../26_自动售货机/26_VendingMachine_讲解.md)
