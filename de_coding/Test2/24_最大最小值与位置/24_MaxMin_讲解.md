# 24 · 8 个数找最大值、最小值和最大值位置

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[MaxMin.v](MaxMin.v) · [MaxMin_tb.v](MaxMin_tb.v)
> 复习优先级：★★☆ ｜ 对应：比较器 + 寄存器 + 计数器（输入协议同 23） ｜ 上机预计：约 40 分钟

## 一、题目可能怎么出

**可能的题面：**"连续输入 8 个数，输出最大值、最小值，以及最大值是第几个"。输入协议和 [23](../23_求和与平均值/23_SumAvg_讲解.md) 一样。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST, START, DIN | input | | 同 23 |
| MAX, MIN | output | 8 | 最大值、最小值 |
| IMAX | output | 3 | 最大值的位置 0–7；有多个相同最大值时报**第一个** |
| DONE | output | 1 | 有效时高一拍 |

## 二、电路思路 + 代码逐段讲

**思路：**保存"目前为止的最大值和最小值"，每来一个新数就和它们比一次（擂台法）。

```verilog
wire new_max  = (DIN > cur_max);                  // 严格大于 → 相同时保留第一个的位置
wire [7:0] max_next  = new_max ? DIN : cur_max;
wire [7:0] min_next  = (DIN < cur_min) ? DIN : cur_min;
wire [2:0] imax_next = new_max ? cnt : cur_imax;

IDLE: if (START) begin cur_max <= DIN; cur_min <= DIN; cur_imax <= 0; cnt <= 1; ... end
RUN:  begin cur_max <= max_next; cur_min <= min_next; cur_imax <= imax_next; ...
            if (cnt == N-1) begin MAX <= max_next; ... DONE <= 1; end end
```

- **第一个数同时作为初始最大值和最小值**（不能把最大值初始化成 0、最小值初始化成 0，否则最小值永远是 0）
- `>` 和 `>=` 的区别：`>` 报第一个出现的最大值位置，`>=` 报最后一个（tb 里第 4 组专门测这个，故意改成 `>=` 会 FAIL）
- 硬件：2 个 8 位比较器 + 3 个寄存器 + 计数器

**有符号数：**端口和寄存器声明 `signed`，比较时用 `$signed()`，否则 −1（0xFF）会被当成 255。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 定向组：全相等（IMAX 应为 0）、递增（最大在 7）、递减（最小在 7）、最大值在最后一个、**最大值出现两次**（应报第一个位置 2）、最小值在中间
- 再加 54 组随机，组间随机空拍，第 6 个数同时给 START 必须被忽略
- 故意把 `>` 改成 `>=`，第 4 组会 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_MaxMin`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_MaxMin` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `MaxMin` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `MaxMin` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `MaxMin.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../MaxMin.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/MaxMin.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_MaxMin.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `MaxMin`，instance 写 `MaxMin_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_MaxMin
cd Test2_MaxMin
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_MaxMin/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit MaxMin.v MaxMin_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./MaxMin_tb.v ./MaxMin.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 60 blocks, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `MaxMin_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：START、DIN、cur_max、cur_min、cur_imax、cnt、MAX、MIN、IMAX、DONE。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_MaxMin/Synthesis
cp ../Behavioral/MaxMin.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/MaxMin/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/MaxMin.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/MaxMin.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_MaxMin/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `MaxMin` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_MaxMin/Synthesis/netlist/      # 要有 Syn_MaxMin.v  Syn_MaxMin.sdf  Syn_MaxMin.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_MaxMin/rtl
cp ../Synthesis/netlist/Syn_MaxMin.v ../Synthesis/netlist/Syn_MaxMin.sdf .
cp ../Behavioral/MaxMin_tb.v .
ls                      # 要有 Syn_MaxMin.v  Syn_MaxMin.sdf  MaxMin_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./MaxMin_tb.v ./Syn_MaxMin.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_MaxMin.v`（网表）**，不是 `MaxMin.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 60 blocks, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_MaxMin/rtl/PowerAnalysis
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
read_verilog ../Syn_MaxMin.v
current_design MaxMin
link
read_saif -input ./inter.saif -instance MaxMin_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `MaxMin_tb/U1`）
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

**Q：N 个数找最大值，串行和并行各需要多少硬件？**
串行（本题）：1 个比较器，N 个周期。并行（比较树）：N−1 个比较器，log₂N 级，1 个周期（组合延时较长）。

**Q：最小值寄存器能初始化成 255 吗？**
可以（最小值初始化成最大可能值，最大值初始化成 0），这样第一个数也走正常的比较流程。本题用"第一个数直接装进去"，两种都对。

**Q：怎么同时找第二大的数？**
再加一个寄存器：新数 > 最大值时，旧最大值降为第二大；否则如果新数 > 第二大，更新第二大。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：23 8 个数求和、求平均](../23_求和与平均值/23_SumAvg_讲解.md) ｜ [下一题：25 交通灯控制器（主路 / 支路 + 车辆传感器）](../25_交通灯控制器/25_TrafficLight_讲解.md)
