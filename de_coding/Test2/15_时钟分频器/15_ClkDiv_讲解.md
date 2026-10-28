# 15 · 时钟分频器（4 分频 + 5 分频，50% 占空比）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[ClkDiv.v](ClkDiv.v) · [ClkDiv_tb.v](ClkDiv_tb.v)
> 复习优先级：★☆☆ ｜ 对应：时序逻辑（奇数分频是经典面试题） ｜ 上机预计：约 45 分钟

## 一、题目可能怎么出

**可能的题面：**"设计一个 4 分频电路""设计一个 5 分频、占空比 50% 的电路"。偶数分频很简单，奇数分频 50% 占空比是经典题。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 输入时钟（周期 T = 20 ns）、异步复位 |
| DIV4 | output | 周期 4T = 80 ns，高 40 ns |
| DIV5 | output | 周期 5T = 100 ns，高 50 ns |

## 二、电路思路 + 代码逐段讲

**4 分频：2 位计数器的最高位**

```verilog
cnt4 <= cnt4 + 1;          // 0,1,2,3,0,...
assign DIV4 = cnt4[1];     // 0,0,1,1 → 高 2 拍、低 2 拍
```

偶数 N 分频的通用方法：计数到 N/2 − 1 就翻转一次输出。

**5 分频（奇数）：同时用上升沿和下降沿**

5 个周期要高 2.5 个周期，只用上升沿做不到半个周期，所以：

```
CLK   _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
cnt5    0   1   2   3   4   0
p     ‾‾‾‾‾‾‾‾|_____________|‾‾‾     上升沿 FF：cnt5 = 0,1 时为 1（2 个周期）
n     __|‾‾‾‾‾‾‾‾|_____________|     下降沿 FF：p 晚半个周期
DIV5  ‾‾‾‾‾‾‾‾‾‾|__________|‾‾‾     p | n → 2.5 个周期
```

```verilog
always @(posedge CLK ...) begin
    cnt5 <= (cnt5 == 4) ? 0 : cnt5 + 1;
    p    <= (cnt5 == 4) || (cnt5 == 0);   // 下一拍 cnt5 是 0 或 1 时 p = 1
end
always @(negedge CLK ...) n <= p;        // 下降沿采样
assign DIV5 = p | n;
```

p 和 n 都直接来自触发器，或门的两个输入不会同时跳变（一个在上升沿、一个在下降沿），所以 DIV5 没有毛刺。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 不比较每个周期的值，而是**测时间**：记录 DIV4/DIV5 的上升沿、下降沿时刻
- 周期 = 两次上升沿的间隔；高电平时间 = 下降沿 − 上一个上升沿
- 允许 ±1 ns 误差（门级仿真有门延时）
- `function ok(...)`：tb 里写一个小函数判断"差不多相等"

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_ClkDiv`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_ClkDiv` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `ClkDiv` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `ClkDiv` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `ClkDiv.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../ClkDiv.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/ClkDiv.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_ClkDiv.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `ClkDiv`，instance 写 `ClkDiv_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_ClkDiv
cd Test2_ClkDiv
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_ClkDiv/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit ClkDiv.v ClkDiv_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./ClkDiv_tb.v ./ClkDiv.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: DIV4 period 80.0 ns high 40.0 ns | DIV5 period 100.0 ns high 50.0 ns | 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `ClkDiv_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：CLK、DIV4、DIV5，再从 U1 拖出 cnt5、p、n：DIV5 = p | n，高电平 2.5 个周期。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_ClkDiv/Synthesis
cp ../Behavioral/ClkDiv.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/ClkDiv/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/ClkDiv.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/ClkDiv.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_ClkDiv/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `ClkDiv` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_ClkDiv/Synthesis/netlist/      # 要有 Syn_ClkDiv.v  Syn_ClkDiv.sdf  Syn_ClkDiv.sdc
```

> [!note] 综合时的提示
> n 是**下降沿**触发的 FF，从 p（上升沿 FF）到 n 只有半个周期，时序报告里这条路径的 required time 是 10 ns 而不是 20 ns，这是正常的。DIV4/DIV5 在这里当普通输出处理；真正的芯片里分频出来的时钟要用 `create_generated_clock` 告诉工具。

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_ClkDiv/rtl
cp ../Synthesis/netlist/Syn_ClkDiv.v ../Synthesis/netlist/Syn_ClkDiv.sdf .
cp ../Behavioral/ClkDiv_tb.v .
ls                      # 要有 Syn_ClkDiv.v  Syn_ClkDiv.sdf  ClkDiv_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./ClkDiv_tb.v ./Syn_ClkDiv.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_ClkDiv.v`（网表）**，不是 `ClkDiv.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: DIV4 period 80.0 ns high 40.0 ns | DIV5 period 100.0 ns high 50.0 ns | 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_ClkDiv/rtl/PowerAnalysis
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
read_verilog ../Syn_ClkDiv.v
current_design ClkDiv
link
read_saif -input ./inter.saif -instance ClkDiv_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `ClkDiv_tb/U1`）
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

**Q：为什么不直接用计数器的组合逻辑输出当时钟？**
组合逻辑输出可能有毛刺，当时钟用会多触发；分频时钟要从 FF 直接输出。

**Q：分频时钟在综合时要怎么处理？**
用 `create_generated_clock` 定义，否则工具不知道它是时钟，不会做正确的时序分析，也不会给它做时钟树。

**Q：3 分频 50% 怎么做？**
同样方法：计数 0,1,2，p 在 cnt=0 时为 1（1 个周期），n 是 p 延迟半个周期，DIV3 = p | n → 1.5 个周期高。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：14 4 位 LFSR（伪随机序列发生器）](../14_四位线性反馈移位寄存器/14_LFSR4_讲解.md) ｜ [下一题：16 改错题](../16_代码改错/16_Debug_讲解.md)
