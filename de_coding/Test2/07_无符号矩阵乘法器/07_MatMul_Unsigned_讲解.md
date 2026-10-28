# 07 · Module 5 矩阵乘法器：无符号版

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[MatrixMultiplier.v](MatrixMultiplier.v) · [MatrixMultiplier_tb.v](MatrixMultiplier_tb.v) · [InputVector.txt](InputVector.txt)
> 复习优先级：★★☆ ｜ 对应：Module 5 变体 ｜ 上机预计：约 50 分钟（脚本不用改名）

## 一、题目可能怎么出

**可能的题面：**
- "把 Module 5 的矩阵乘法器改成无符号 8 位输入"；或者"改成 4 位输入""改成 16 位输入"。
- 本题的核心是：**有符号 → 无符号**要改哪些地方，**位宽**怎么算。

`OUT = A1·B1 + A0·B0`，A、B 都是无符号 8 位（0–255）。

**位宽计算：**最大值 255×255 + 255×255 = 130050 < 2¹⁷ = 131072，所以 OUT 还是 17 位。
（一般规律：N 位 × N 位 = 2N 位；两个相加再 +1 位 → 2N+1 位。）

## 二、电路思路 + 代码逐段讲

在你 Module 5 代码的基础上**只改三类地方**（代码里都标了 `CHANGED`）：

| | 有符号（原来） | 无符号（现在） |
|---|---|---|
| 端口 | `input wire signed [7:0] A` | `input wire [7:0] A` |
| 乘法 | `$signed(A) * $signed(B)` | `A * B` |
| 扩展到 17 位 | `{product_reg[15], product_reg}`（**符号**扩展：补最高位） | `{1'b0, product_reg}`（**零**扩展：补 0） |

**为什么扩展方式不同：**
- 有符号数 −1 = `16'hFFFF`，扩展成 17 位要补 1：`17'h1FFFF`，值还是 −1
- 无符号数 65535 = `16'hFFFF`，扩展要补 0：`17'h0FFFF`，值还是 65535
- 补错了，负数会变成很大的正数，或者大正数变成负数

**架构不变**（手册 Fig. 3）：状态机产生 EN1/EN2/EN3
- EN1：乘法器寄存器采样 A×B
- EN2：累加器 `acc = (第一项 ? 0 : acc) + product`
- EN3：结果放到 OUT，同时 OUT_STROBE 拉高一拍
- 每组数据 5 个周期：IDLE/MUL_FIRST → ACC_FIRST → MUL_SECOND → ACC_SECOND → OUTPUT

**改成 4 位输入：**A、B 改 `[3:0]`，product 改 `[7:0]`，acc/OUT 改 `[8:0]`，零扩展改 `{1'b0, product_reg}`（9 位）。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 和你 Module 5 的 tb 协议一样：下降沿给 A1/B1（第一组同时给 START=1），下一个下降沿给 A0/B0，再等 4 个上升沿
- `InputVector.txt` 第一行是注释，会被 `$fgets` 跳过；之后每行 `A1 B1 A0 B0`（十进制）
- 检查器：每个上升沿后 2 ns，如果 OUT_STROBE=1 就和 `a1*b1 + a0*b0` 比较
- 测试数据包含边界：全 0、`255 255 255 255`（最大值 130050）、一边是 0 一边最大
- 和有符号版 tb 的区别：A/B/OUT 去掉 `signed`，比较时不用 `$signed(OUT)`

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_MatrixMultiplier`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_MatrixMultiplier` |
| 模块名 / 脚本名 | `MatrixMultiplier` | **不用改**（本题模块名和 Module5 一样） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_MatrixMultiplier.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `MatrixMultiplier`，instance 写 `MatrixMultiplier_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_MatrixMultiplier
cd Test2_MatrixMultiplier
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_MatrixMultiplier/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit MatrixMultiplier.v MatrixMultiplier_tb.v InputVector.txt &
```

gedit 会打开 3 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./MatrixMultiplier_tb.v ./MatrixMultiplier.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 10 vectors, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `MatrixMultiplier_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、OUT 设成 **Unsigned**（不是 Signed），OUT_STROBE 每 5 个周期一个脉冲。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_MatrixMultiplier/Synthesis
cp ../Behavioral/MatrixMultiplier.v sources/
ls sources/ scripts/
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/MatrixMultiplier.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_MatrixMultiplier/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `MatrixMultiplier` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_MatrixMultiplier/Synthesis/netlist/      # 要有 Syn_MatrixMultiplier.v  Syn_MatrixMultiplier.sdf  Syn_MatrixMultiplier.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_MatrixMultiplier/rtl
cp ../Synthesis/netlist/Syn_MatrixMultiplier.v ../Synthesis/netlist/Syn_MatrixMultiplier.sdf .
cp ../Behavioral/MatrixMultiplier_tb.v ../Behavioral/InputVector.txt .
ls                      # 要有 Syn_MatrixMultiplier.v  Syn_MatrixMultiplier.sdf  MatrixMultiplier_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./MatrixMultiplier_tb.v ./Syn_MatrixMultiplier.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_MatrixMultiplier.v`（网表）**，不是 `MatrixMultiplier.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 10 vectors, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_MatrixMultiplier/rtl/PowerAnalysis
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
read_verilog ../Syn_MatrixMultiplier.v
current_design MatrixMultiplier
link
read_saif -input ./inter.saif -instance MatrixMultiplier_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `MatrixMultiplier_tb/U1`）
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

**Q：Verilog 里 `signed` 和 `$signed()` 有什么区别？**
`signed` 是声明时就规定这个信号按有符号数处理；`$signed()` 是在表达式里临时把一个信号当成有符号数。表达式里**只要有一个操作数是无符号，整个表达式都按无符号算**，所以 Module 5 里乘法两边都加了 `$signed`。

**Q：DesignWare 乘法器 `DW_mult_tc` 和 `DW_mult_uns` 是什么？**
综合工具对 `*` 自动调用的库组件。tc = two's complement（有符号），uns = unsigned（无符号）。改成无符号后原理图里应该会看到 uns 版本。

**Q：无符号版比有符号版面积大还是小？**
基本差不多（乘法器结构类似），有符号版需要处理符号位，可以用 `report_area` 对比。

**Q：-128 × -128 在有符号 8 位里会溢出吗？**
乘积 16384 需要 16 位有符号数表示（最大 32767），所以 16 位的 product 够用；但如果只用 15 位就会溢出。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：06 全加器 56 种输入跳变 + 关键延时](../06_全加器56种跳变/06_FullAdder_All56_讲解.md) ｜ [下一题：08 三项点积 A2·B2 + A1·B1 + A0·B0](../08_三项点积/08_DotProduct3_讲解.md)
