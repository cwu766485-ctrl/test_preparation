# 14 · 4 位 LFSR（伪随机序列发生器）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[LFSR4.v](LFSR4.v) · [LFSR4_tb.v](LFSR4_tb.v)
> 复习优先级：★☆☆ ｜ 对应：时序逻辑（DFT / BIST 相关） ｜ 上机预计：约 40 分钟

## 一、题目可能怎么出

**可能的题面：**"用多项式 x⁴ + x³ + 1 设计一个 4 位 LFSR，验证它的周期是 15"。也可能在笔试里问"LFSR 为什么不能全 0"。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位（复位成 0001） |
| EN | input | 1 = 走一步 |
| Q[3:0] | output | 当前状态 |

## 二、电路思路 + 代码逐段讲

**LFSR = 移位寄存器 + 异或反馈**

```verilog
wire fb = Q[3] ^ Q[2];             // 抽头：x^4 → Q[3]，x^3 → Q[2]
always @(posedge CLK or negedge NRST)
    if (!NRST)    Q <= 4'b0001;    // 种子：任意非 0
    else if (EN)  Q <= {Q[2:0], fb};
```

推几步：

| 步 | Q | fb = Q3⊕Q2 |
|---|---|---|
| 0 | 0001 | 0 |
| 1 | 0010 | 0 |
| 2 | 0100 | 1 |
| 3 | 1001 | 1 |
| 4 | 0011 | 0 |
| 5 | 0110 | 1 |
| … | … | … |
| 15 | 0001（回到起点） | |

- **最大长度序列：**n 位 LFSR 最多 2ⁿ − 1 个状态（4 位 = 15），前提是多项式是"本原多项式"（primitive）。x⁴+x³+1 是本原的
- **为什么不能是 0000：**0 ⊕ 0 = 0，全 0 会一直保持全 0（锁死），所以复位值必须非 0，而且序列里不会出现 0

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 每一步检查 `Q == {prev[2:0], prev[3]^prev[2]}`
- 检查从不出现 0000
- 记录第几步回到种子 → 周期必须是 15
- `seen` 是 16 位的标记，`seen[v] = 1` 表示状态 v 出现过；最后应该是 `16'hFFFE`（1–15 都出现、0 没出现）

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_LFSR4`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_LFSR4` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `LFSR4` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `LFSR4` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `LFSR4.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../LFSR4.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/LFSR4.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_LFSR4.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `LFSR4`，instance 写 `LFSR4_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_LFSR4
cd Test2_LFSR4
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_LFSR4/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit LFSR4.v LFSR4_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./LFSR4_tb.v ./LFSR4.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: period = 15, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `LFSR4_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：Q 设成 Unsigned：1, 2, 4, 9, 3, 6, 13, 10, 5, 11, 7, 15, 14, 12, 8, 1 …… 15 个数循环，没有 0。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_LFSR4/Synthesis
cp ../Behavioral/LFSR4.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/LFSR4/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/LFSR4.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/LFSR4.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_LFSR4/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `LFSR4` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_LFSR4/Synthesis/netlist/      # 要有 Syn_LFSR4.v  Syn_LFSR4.sdf  Syn_LFSR4.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_LFSR4/rtl
cp ../Synthesis/netlist/Syn_LFSR4.v ../Synthesis/netlist/Syn_LFSR4.sdf .
cp ../Behavioral/LFSR4_tb.v .
ls                      # 要有 Syn_LFSR4.v  Syn_LFSR4.sdf  LFSR4_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./LFSR4_tb.v ./Syn_LFSR4.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_LFSR4.v`（网表）**，不是 `LFSR4.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: period = 15, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_LFSR4/rtl/PowerAnalysis
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
read_verilog ../Syn_LFSR4.v
current_design LFSR4
link
read_saif -input ./inter.saif -instance LFSR4_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `LFSR4_tb/U1`）
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

**Q：LFSR 有什么用？**
产生伪随机测试图形（BIST，内建自测试）、CRC 校验、通信里的扰码、加密里的流密码。

**Q：Fibonacci 型和 Galois 型 LFSR 的区别？**
Fibonacci：几个抽头异或后送回第一级（本题）；Galois：反馈直接异或进中间几级，每级之间最多一个 XOR，速度更快。两者序列相同但相位不同。

**Q：n 位 LFSR 的最长周期？**
2ⁿ − 1（去掉全 0 状态）。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：13 4 位移位寄存器（串入并出 SIPO）](../13_四位移位寄存器/13_ShiftReg4_讲解.md) ｜ [下一题：15 时钟分频器（4 分频 + 5 分频，50% 占空比）](../15_时钟分频器/15_ClkDiv_讲解.md)
