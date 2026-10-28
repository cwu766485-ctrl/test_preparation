# 13 · 4 位移位寄存器（串入并出 SIPO）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[ShiftReg4.v](ShiftReg4.v) · [ShiftReg4_tb.v](ShiftReg4_tb.v)
> 复习优先级：★★☆ ｜ 对应：时序逻辑 + 阻塞/非阻塞 ｜ 上机预计：约 45 分钟

## 一、题目可能怎么出

**可能的题面：**"设计一个 4 位串入并出移位寄存器"；变体：并入串出（PISO，带 LOAD）、左右双向移位、环形计数器。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位 |
| EN | input | 1 = 这一拍移位 |
| SIN | input | 串行输入 |
| Q[3:0] | output | 并行输出 |
| SOUT | output | 串行输出 = Q[3] |

## 二、电路思路 + 代码逐段讲

```verilog
always @(posedge CLK or negedge NRST)
    if (!NRST)    Q <= 4'b0000;
    else if (EN)  Q <= {Q[2:0], SIN};     // 拼接：低 3 位左移，SIN 补到最低位
assign SOUT = Q[3];
```

例子：Q = `0110`，SIN = 1 → 新 Q = `{110, 1}` = `1101`。

**这题是笔试"阻塞 vs 非阻塞"的标准例子：**

```verilog
// ✔ 非阻塞：右边全部用"旧值"，四个 FF 同时更新
Q[3] <= Q[2]; Q[2] <= Q[1]; Q[1] <= Q[0]; Q[0] <= SIN;

// ✘ 阻塞，按这个顺序：Q[0] 先被改成 SIN，Q[1] 读到的是新的 Q[0]……
Q[0] = SIN; Q[1] = Q[0]; Q[2] = Q[1]; Q[3] = Q[2];
// 结果：一个时钟后四位全等于 SIN，综合出来也只剩 1 个有效的 FF
```

**规则：时序 always 块一律用 `<=`。**

**变体：**
- 右移：`Q <= {SIN, Q[3:1]};`
- 并入串出：加 `LOAD`、`D[3:0]`：`if (LOAD) Q <= D; else if (EN) Q <= {Q[2:0], 1'b0};`
- 环形计数器：复位成 `4'b0001`，`Q <= {Q[2:0], Q[3]};`

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 随机 SIN、随机 EN（前 4 拍 EN 强制为 1，保证先填满）
- 参考模型 `ref_q <= {ref_q[2:0], SIN}`，每个上升沿后 2 ns 比较

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_ShiftReg4`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_ShiftReg4` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `ShiftReg4` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `ShiftReg4` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `ShiftReg4.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../ShiftReg4.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/ShiftReg4.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_ShiftReg4.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `ShiftReg4`，instance 写 `ShiftReg4_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_ShiftReg4
cd Test2_ShiftReg4
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_ShiftReg4/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit ShiftReg4.v ShiftReg4_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./ShiftReg4_tb.v ./ShiftReg4.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `ShiftReg4_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：SIN、EN、Q（Binary）：每个上升沿（EN=1 时）新的 SIN 从 Q[0] 进去，旧的往高位挪一格。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_ShiftReg4/Synthesis
cp ../Behavioral/ShiftReg4.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/ShiftReg4/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/ShiftReg4.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/ShiftReg4.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_ShiftReg4/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `ShiftReg4` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_ShiftReg4/Synthesis/netlist/      # 要有 Syn_ShiftReg4.v  Syn_ShiftReg4.sdf  Syn_ShiftReg4.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_ShiftReg4/rtl
cp ../Synthesis/netlist/Syn_ShiftReg4.v ../Synthesis/netlist/Syn_ShiftReg4.sdf .
cp ../Behavioral/ShiftReg4_tb.v .
ls                      # 要有 Syn_ShiftReg4.v  Syn_ShiftReg4.sdf  ShiftReg4_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./ShiftReg4_tb.v ./Syn_ShiftReg4.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_ShiftReg4.v`（网表）**，不是 `ShiftReg4.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_ShiftReg4/rtl/PowerAnalysis
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
read_verilog ../Syn_ShiftReg4.v
current_design ShiftReg4
link
read_saif -input ./inter.saif -instance ShiftReg4_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `ShiftReg4_tb/U1`）
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

**Q：两个 always 块互相交换值，用 `=` 和 `<=` 结果分别是什么？**
`a = b; b = a;` → 两个都等于原来的 b；`a <= b; b <= a;` → 成功交换。

**Q：移位寄存器有什么用？**
串并转换（UART、SPI）、延迟线、LFSR（见 [14](../14_四位线性反馈移位寄存器/14_LFSR4_讲解.md)）、扫描链（DFT 里把所有 FF 串成一个大移位寄存器）。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：12 4 选 1 多路选择器（Mux4）](../12_四选一多路选择器/12_Mux4_讲解.md) ｜ [下一题：14 4 位 LFSR（伪随机序列发生器）](../14_四位线性反馈移位寄存器/14_LFSR4_讲解.md)
