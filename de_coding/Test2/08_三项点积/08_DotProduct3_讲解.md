# 08 · 三项点积 A2·B2 + A1·B1 + A0·B0

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[DotProduct3.v](DotProduct3.v) · [DotProduct3_tb.v](DotProduct3_tb.v) · [InputVector.txt](InputVector.txt)
> 复习优先级：★★☆ ｜ 对应：Module 5 变体（1×3 向量乘 3×1 向量） ｜ 上机预计：约 70 分钟

## 一、题目可能怎么出

**可能的题面：**
- "把 Module 5 改成 [A2 A1 A0] × [B2 B1 B0]ᵀ"，或者"改成 1×4 的向量"。
- 考点：状态机要多走几拍、累加器位宽要加宽。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| START | input | 1 | IDLE 时为 1：这一拍总线上是 A2/B2 |
| A, B | input | 8 signed | 三个周期依次送 A2/B2、A1/B1、A0/B0 |
| OUT | output | 18 signed | 结果 |
| OUT_STROBE | output | 1 | OUT 有效时高一拍 |

**位宽：**每个乘积 16 位；3 项相加需要多 ⌈log₂3⌉ = 2 位 → **18 位**。
（规律：K 项相加，位宽 + ⌈log₂K⌉。2 项 +1，3–4 项 +2，5–8 项 +3。）

## 二、电路思路 + 代码逐段讲

这里用一个比 Module 5 更简单的结构：**乘法和累加在同一拍完成**（乘累加，MAC），用计数器 `cnt` 记录现在是第几项。

```
周期:     1        2        3        4        5        6
总线:   A2,B2    A1,B1    A0,B0    A2',B2'  A1',B1'  A0',B0'
cnt:      0        1        2        0        1        2
acc:   A2B2     +A1B1    +A0B0 → OUT                  → OUT'
STROBE:                    ↑1                          ↑1
```

```verilog
wire active = (state == RUN) || START;           // IDLE 时 START=1 那一拍就开始
wire signed [15:0] p     = $signed(A) * $signed(B);
wire signed [17:0] p_ext = {{2{p[15]}}, p};       // 符号扩展：复制 2 次最高位
wire signed [17:0] base  = (cnt == 0) ? 0 : acc;  // 第一项时把旧和丢掉
wire signed [17:0] sum   = base + p_ext;
```

- `{2{p[15]}}`：**复制拼接**，把 p[15] 复制 2 次。`{4{1'b1}}` = `4'b1111`
- 每拍：`acc <= sum`；`cnt == 2` 时 `OUT <= sum; OUT_STROBE <= 1; cnt <= 0`
- `OUT_STROBE <= 1'b0;` 写在最前面当默认值，后面的 `<= 1` 会覆盖它 → 自动变成一拍的脉冲（非阻塞赋值，同一 always 块里**最后一次赋值生效**）

**和 Module 5 结构的对比：**Module 5 把乘法和累加分在两拍（中间有 product_reg），关键路径更短，但每组要 5 拍。这里一拍做完乘加，每组只要 3 拍，但关键路径 = 乘法器 + 加法器。20 ns 周期下完全够用，可以用 `report_timing` 看 slack。

**扩展到 4 项：**`cnt == 3` 时输出，位宽仍为 18（4 项也是 +2 位），tb 每组多送一拍。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 每行 6 个数：`A2 B2 A1 B1 A0 B0`（十进制，可以是负数）
- 每个下降沿送一项，**中间不停**，3 拍一组；START 只在最开始给一次
- 测试数据包含最坏情况：三个 (−128)×(−128) = 49152、三个 127×(−128) = −48768
- 检查用 `$signed(OUT)` 和整数 expected 比较

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_DotProduct3`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_DotProduct3` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `DotProduct3` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `DotProduct3` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `DotProduct3.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../DotProduct3.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/DotProduct3.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_DotProduct3.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `DotProduct3`，instance 写 `DotProduct3_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_DotProduct3
cd Test2_DotProduct3
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_DotProduct3/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit DotProduct3.v DotProduct3_tb.v InputVector.txt &
```

gedit 会打开 3 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./DotProduct3_tb.v ./DotProduct3.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 8 vectors, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `DotProduct3_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、OUT 设成 **Signed Decimal**；OUT_STROBE 每 3 个周期一个脉冲。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_DotProduct3/Synthesis
cp ../Behavioral/DotProduct3.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/DotProduct3/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/DotProduct3.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/DotProduct3.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_DotProduct3/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `DotProduct3` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_DotProduct3/Synthesis/netlist/      # 要有 Syn_DotProduct3.v  Syn_DotProduct3.sdf  Syn_DotProduct3.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_DotProduct3/rtl
cp ../Synthesis/netlist/Syn_DotProduct3.v ../Synthesis/netlist/Syn_DotProduct3.sdf .
cp ../Behavioral/DotProduct3_tb.v ../Behavioral/InputVector.txt .
ls                      # 要有 Syn_DotProduct3.v  Syn_DotProduct3.sdf  DotProduct3_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./DotProduct3_tb.v ./Syn_DotProduct3.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_DotProduct3.v`（网表）**，不是 `DotProduct3.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 8 vectors, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_DotProduct3/rtl/PowerAnalysis
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
read_verilog ../Syn_DotProduct3.v
current_design DotProduct3
link
read_saif -input ./inter.saif -instance DotProduct3_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `DotProduct3_tb/U1`）
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

**Q：为什么是 18 位而不是 17 位？**
按规律 3 项要 +2 位。实际最大值 3 × 16384 = 49152，17 位有符号（最大 65535）其实也放得下；但按通用规则取 18 位最保险，答题时说明计算过程即可。

**Q：乘累加放在一拍和分两拍各有什么优缺点？**
一拍：延迟少、寄存器少，但关键路径长（乘法 + 加法），最高频率低。两拍（流水线）：关键路径短、频率高，但多一级寄存器、多一拍延迟。

**Q：OUT_STROBE 为什么只高一拍？**
每个时钟沿先默认赋 0，只有 cnt==2 那一拍再赋 1。非阻塞赋值在同一个块里后写的覆盖先写的。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：07 Module 5 矩阵乘法器：无符号版](../07_无符号矩阵乘法器/07_MatMul_Unsigned_讲解.md) ｜ [下一题：09 乘累加器 MAC（ACC += A×B）](../09_乘累加器/09_MAC_讲解.md)
