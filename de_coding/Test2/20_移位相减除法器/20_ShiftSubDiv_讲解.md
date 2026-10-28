# 20 · 移位相减除法器（恢复余数法，8÷8）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[ShiftSubDiv.v](ShiftSubDiv.v) · [ShiftSubDiv_tb.v](ShiftSubDiv_tb.v)
> 复习优先级：★★☆ ｜ 对应：18 乘法器的对称题：1 个减法器 + 移位 + 计数器 ｜ 上机预计：约 80 分钟

## 一、题目可能怎么出

**可能的题面：**"用移位相减的方法实现 8 位无符号除法器，输出商和余数"。是 [18 移位相加乘法器](../18_移位相加乘法器/18_ShiftAddMul_讲解.md) 的对称题：**乘法 = 移位 + 加，除法 = 移位 + 减**。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| START | input | 1 | IDLE 时为 1：锁存 A、B，开始（忙时忽略） |
| A, B | input | 8 | 被除数、除数（无符号） |
| Q, R | output | 8 | 商、余数：A = Q·B + R，R < B |
| DIV0 | output | 1 | 除数为 0 时为 1（此时 Q = 255，R = A） |
| DONE | output | 1 | 结果有效时高一拍 |

时序：W + 1 = 9 个周期。

## 二、电路思路 + 代码逐段讲

**原理就是二进制竖式除法**：从最高位开始，每拍"落下"被除数的一位，够减就减，商记 1，不够商记 0。

```verilog
wire [W:0] trial = {rem, qa[W-1]};             // 余数左移，落下被除数的下一位
wire       ge    = (trial >= {1'b0, divisor});  // 够不够减
wire [W:0] diff  = trial - {1'b0, divisor};     // 唯一的减法器

RUN: begin
    rem <= ge ? diff[W-1:0] : trial[W-1:0];      // 够减就减，不够就保留
    qa  <= {qa[W-2:0], ge};                      // 被除数的位从高位移出，商位从低位移入
    if (cnt == W-1) begin Q <= {qa[W-2:0], ge}; R <= ...; DONE <= 1; ... end
end
```

**省寄存器的小技巧：**`qa` 一开始装的是 A。每拍左移一位：A 的最高位被"用掉"（落到 trial 里），空出来的最低位正好放新的商位。W 拍后 A 全部移出，`qa` 里就是完整的商。

**逐拍演示：13 ÷ 4，取 4 位**（A = 1101，B = 0100）

| 拍 | trial = {rem, 下一位} | ≥ 4？ | 商位 | 新 rem |
|---|---|---|---|---|
| 1 | {0, 1} = 1 | 否 | 0 | 1 |
| 2 | {1, 1} = 3 | 否 | 0 | 3 |
| 3 | {3, 0} = 6 | 是 | 1 | 6 − 4 = 2 |
| 4 | {2, 1} = 5 | 是 | 1 | 5 − 4 = 1 |

商 0011 = **3**，余数 **1** ✔（13 = 3 × 4 + 1）。

**为什么 trial 要 W+1 位：**rem 最大是 B−1，左移一位再加 1 可能达到 2B−1，会超过 W 位。

**除以 0：**每拍 trial ≥ 0 都成立，商全是 1（255），余数就是 A。用 DIV0 标出来，这比让电路卡死好。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- task `run_div(a, b)`：给输入 → 等 DONE → 和 `a / b`、`a % b` 比较，并检查 DONE 正好在第 9 个时钟
- 边界：13/4、100/7、255/1、255/255、0/5、7/9（商 0）、除以 0
- 默认 300 组随机；加 `+define+FULL` **穷举 65536 组**（我跑过，0 errors）
- 故意把 `>=` 改成 `>`（刚好相等时不减），tb 报 15 个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_ShiftSubDiv`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_ShiftSubDiv` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `ShiftSubDiv` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `ShiftSubDiv` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `ShiftSubDiv.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../ShiftSubDiv.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/ShiftSubDiv.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_ShiftSubDiv.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `ShiftSubDiv`，instance 写 `ShiftSubDiv_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

在 Linux 文件管理器进入 `~/NM6008`，选中整个 `Module5` 文件夹 → **Ctrl+C → Ctrl+V** → 将新副本重命名为 `Test2_ShiftSubDiv`。如果已经有可用的练习副本，就直接使用它；后续终端路径中的工程名相应替换。

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_ShiftSubDiv/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit ShiftSubDiv.v ShiftSubDiv_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./ShiftSubDiv_tb.v ./ShiftSubDiv.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 311 divisions, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `ShiftSubDiv_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、rem、qa（Binary）、trial、ge、Q、R、cnt、DONE。每拍 qa 左移一位、最低位填进新的商位，ge=1 的拍 rem 减掉除数。

### 第 2 步：综合（终端 T2）

**2.1 用文件管理器放 RTL、改脚本名字：**同时打开本工程的 `Behavioral/` 和 `Synthesis/sources/`，从前者选中 `ShiftSubDiv.v` → **Ctrl+C** → 到后者 **Ctrl+V**；tb 不复制。若询问替换，核对是否为 T1 通过的新版。

再打开 `Synthesis/scripts/`，将 `MatrixMultiplier.tcl` 在文件管理器中重命名为 `ShiftSubDiv.tcl`。用 gedit 修改其中的顶层设计名，并修改 `ReadVerilogFiles.tcl`（每个设计 `.v` 一行 `read_verilog`）和 `run_topdown.tcl`（引用新的顶层 Tcl）。**不要在终端批量替换所有旧字符串**：旧名字可能仍是本题用到的子模块，例如 `FullAdder.v`。

`cat` 出来应该是：`read_verilog ./sources/ShiftSubDiv.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路先确认 `CLK` 的 `create_clock` 有效，练习时 `CLK_PERIOD` 为 **20 ns**；`uncertainty`、输入/输出延时按原模板和题目要求核对，不要机械地取消所有注释。需要修改时用 gedit 打开 `scripts/MyDefaults.con`。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_ShiftSubDiv/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `ShiftSubDiv` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_ShiftSubDiv/Synthesis/netlist/      # 要有 Syn_ShiftSubDiv.v 和 Syn_ShiftSubDiv.sdf；.sdc 若生成可归档
```

### 第 3 步：门级仿真（T3）

在 Linux 文件管理器里，把本次 `Synthesis/netlist/` 的 `Syn_ShiftSubDiv.v`、`Syn_ShiftSubDiv.sdf` 一起复制到 `rtl/`；再从 `Behavioral/` 把 `ShiftSubDiv_tb.v` 复制到 `rtl/`。若出现同名文件，核对新文件的修改时间后选择替换；保留 `rtl/library.f`。随后在 `rtl/` 打开终端：

```csh
ls                      # 要有 Syn_ShiftSubDiv.v  Syn_ShiftSubDiv.sdf  ShiftSubDiv_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./ShiftSubDiv_tb.v ./Syn_ShiftSubDiv.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_ShiftSubDiv.v`（网表）**，不是 `ShiftSubDiv.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 311 divisions, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_ShiftSubDiv/rtl/PowerAnalysis
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
read_verilog ../Syn_ShiftSubDiv.v
current_design ShiftSubDiv
link
read_saif -input ./inter.saif -instance ShiftSubDiv_tb/U1
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

- 只有 `pa.tcl` 执行了 `report_saif > rpt_saif.txt` 才会生成这份文件。检查活动是否映射到 DUT；覆盖率不到 100% 不一定是错误，需核对 `-instance`（本题为 `ShiftSubDiv_tb/U1`）、VPD 是否记录 DUT、网表是否对应及测试范围。
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

**Q：恢复余数除法和不恢复余数除法的区别？**
恢复余数法：先试减，不够减就"恢复"（这里是直接保留 trial，不用真的加回去）。不恢复余数法：不够减时不恢复，下一拍改成加，省掉判断后的选择，速度更快。

**Q：W 位除法需要几个周期？**
W 个周期（加装载 1 拍），每拍出 1 位商。

**Q：有符号除法怎么做？**
先取绝对值做无符号除法，商的符号 = A、B 符号异或，余数的符号跟被除数 A 一样。

**Q：为什么硬件里尽量避免除法？**
除法器要么很慢（每拍 1 位），要么面积很大（组合阵列）。除以 2 的幂直接右移（见 [23](../23_求和与平均值/23_SumAvg_讲解.md) 的求平均）。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：19 位串行加/减法器（教科书版串行加法器）](../19_位串行加减法器/19_BitSerialAddSub_讲解.md) ｜ [下一题：21 位串行比较器（高位先到）](../21_位串行比较器/21_SerialComparator_讲解.md)
