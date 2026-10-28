# 23 · 8 个数求和、求平均

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[SumAvg.v](SumAvg.v) · [SumAvg_tb.v](SumAvg_tb.v)
> 复习优先级：★★☆ ｜ 对应：M5 风格的累加器 + 计数器 ｜ 上机预计：约 40 分钟

## 一、题目可能怎么出

**可能的题面：**"连续输入 8 个 8 位无符号数，输出它们的和与平均值"。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| START | input | 1 | 和**第一个数**一起为 1（只在 IDLE 时有效） |
| DIN | input | 8 | 每拍一个数，8 拍连续 |
| SUM | output | 11 | 和（8 × 255 = 2040 < 2048） |
| AVG | output | 8 | 平均值，向下取整 = SUM >> 3 |
| AVG_R | output | 8 | 平均值，四舍五入 = (SUM + 4) >> 3 |
| DONE | output | 1 | 有效时高一拍（第 8 个数之后的那一拍） |

## 二、电路思路 + 代码逐段讲

**两个要点：**
1. **位宽**：8 个 8 位数相加，最大 2040，需要 8 + log₂8 = **11 位**
2. **除以 8 不需要除法器**：8 = 2³，右移 3 位就是取 SUM 的高 8 位 `SUM[10:3]`，**只是连线，不占门**

```verilog
wire [10:0] acc_next = acc + DIN;
wire [11:0] rnd      = acc_next + 4;           // + N/2 再右移 = 四舍五入

IDLE: if (START) begin acc <= DIN; cnt <= 1; state <= RUN; end   // 第 1 个数
RUN: begin
    acc <= acc_next;  cnt <= cnt + 1;
    if (cnt == N-1) begin                       // 第 8 个数
        SUM <= acc_next;
        AVG <= acc_next[10:3];                  // >> 3
        AVG_R <= rnd[10:3];
        DONE <= 1; state <= IDLE;
    end
end
```

**例：**1 到 8：SUM = 36，36 / 8 = 4.5 → AVG = 4（向下取整），AVG_R = (36 + 4) >> 3 = 5（四舍五入）。

**改成 16 个数：**参数 N = 16、LOGN = 4，SUM 变成 12 位，平均值右移 4 位。N 不是 2 的幂（比如 10 个数）就真的要除法了，可以用 [20 除法器](../20_移位相减除法器/20_ShiftSubDiv_讲解.md)，或者乘一个近似的倒数。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 每组 8 个数，组与组之间随机空 0–3 拍
- 定向组：全 0、全 255（最大和 2040）、1..8（4.5 取整测试）、和为 3（0.375 → 0/0）、和为 4（0.5 → 0/1，测四舍五入的边界）
- 每组的第 4 个数同时给一次 START：**必须被忽略**
- DONE 那拍 DIN 故意给一个乱值 0xA5：不能被加进去

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_SumAvg`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_SumAvg` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `SumAvg` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `SumAvg` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `SumAvg.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../SumAvg.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/SumAvg.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_SumAvg.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `SumAvg`，instance 写 `SumAvg_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

在 Linux 文件管理器进入 `~/NM6008`，选中整个 `Module5` 文件夹 → **Ctrl+C → Ctrl+V** → 将新副本重命名为 `Test2_SumAvg`。如果已经有可用的练习副本，就直接使用它；后续终端路径中的工程名相应替换。

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_SumAvg/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit SumAvg.v SumAvg_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./SumAvg_tb.v ./SumAvg.v -l compile_beh.log
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

DVE：左边点 `SumAvg_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：START、DIN、acc、cnt、SUM、AVG、AVG_R、DONE（数值都设成 Unsigned）。

### 第 2 步：综合（终端 T2）

**2.1 用文件管理器放 RTL、改脚本名字：**同时打开本工程的 `Behavioral/` 和 `Synthesis/sources/`，从前者选中 `SumAvg.v` → **Ctrl+C** → 到后者 **Ctrl+V**；tb 不复制。若询问替换，核对是否为 T1 通过的新版。

再打开 `Synthesis/scripts/`，将 `MatrixMultiplier.tcl` 在文件管理器中重命名为 `SumAvg.tcl`。用 gedit 修改其中的顶层设计名，并修改 `ReadVerilogFiles.tcl`（每个设计 `.v` 一行 `read_verilog`）和 `run_topdown.tcl`（引用新的顶层 Tcl）。**不要在终端批量替换所有旧字符串**：旧名字可能仍是本题用到的子模块，例如 `FullAdder.v`。

`cat` 出来应该是：`read_verilog ./sources/SumAvg.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路先确认 `CLK` 的 `create_clock` 有效，练习时 `CLK_PERIOD` 为 **20 ns**；`uncertainty`、输入/输出延时按原模板和题目要求核对，不要机械地取消所有注释。需要修改时用 gedit 打开 `scripts/MyDefaults.con`。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_SumAvg/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `SumAvg` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_SumAvg/Synthesis/netlist/      # 要有 Syn_SumAvg.v 和 Syn_SumAvg.sdf；.sdc 若生成可归档
```

### 第 3 步：门级仿真（T3）

在 Linux 文件管理器里，把本次 `Synthesis/netlist/` 的 `Syn_SumAvg.v`、`Syn_SumAvg.sdf` 一起复制到 `rtl/`；再从 `Behavioral/` 把 `SumAvg_tb.v` 复制到 `rtl/`。若出现同名文件，核对新文件的修改时间后选择替换；保留 `rtl/library.f`。随后在 `rtl/` 打开终端：

```csh
ls                      # 要有 Syn_SumAvg.v  Syn_SumAvg.sdf  SumAvg_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./SumAvg_tb.v ./Syn_SumAvg.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_SumAvg.v`（网表）**，不是 `SumAvg.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 60 blocks, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_SumAvg/rtl/PowerAnalysis
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
read_verilog ../Syn_SumAvg.v
current_design SumAvg
link
read_saif -input ./inter.saif -instance SumAvg_tb/U1
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

- 只有 `pa.tcl` 执行了 `report_saif > rpt_saif.txt` 才会生成这份文件。检查活动是否映射到 DUT；覆盖率不到 100% 不一定是错误，需核对 `-instance`（本题为 `SumAvg_tb/U1`）、VPD 是否记录 DUT、网表是否对应及测试范围。
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

**Q：为什么右移 3 位就是除以 8？**
二进制里每右移一位就是除以 2（向下取整），右移 3 位 = 除以 2³ = 8。综合后只是连线，没有任何门。

**Q：四舍五入为什么是加 4 再右移？**
加上除数的一半（8/2 = 4）再向下取整，就是四舍五入。

**Q：有符号数求平均要注意什么？**
累加器要做符号扩展；右移要用算术右移 `>>>`（高位补符号位），而且对负数来说向下取整是朝负无穷取整。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：22 2×2 矩阵乘向量（Module 5 扩展成两个输出）](../22_二乘二矩阵乘向量/22_MatVec2x2_讲解.md) ｜ [下一题：24 8 个数找最大值、最小值和最大值位置](../24_最大最小值与位置/24_MaxMin_讲解.md)
