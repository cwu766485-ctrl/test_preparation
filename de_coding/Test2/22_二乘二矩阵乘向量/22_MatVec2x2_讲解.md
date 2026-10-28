# 22 · 2×2 矩阵乘向量（Module 5 扩展成两个输出）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[MatVec2x2.v](MatVec2x2.v) · [MatVec2x2_tb.v](MatVec2x2_tb.v)
> 复习优先级：★★★ ｜ 对应：M5 变体：1 个乘法器 + 1 个累加器 + 计数器 ｜ 上机预计：约 70 分钟

## 一、题目可能怎么出

**可能的题面：**"把 Module 5 的 1×2 乘 2×1 改成 2×2 矩阵乘 2×1 向量"。

```
[Y0]   [M00 M01]   [X0]      Y0 = M00·X0 + M01·X1
[Y1] = [M10 M11] × [X1]      Y1 = M10·X0 + M11·X1
```

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| START | input | 1 | IDLE 时为 1：这一拍是 M00/X0 |
| A, B | input | 8 signed | 矩阵元素、向量元素，**共用总线**，每拍一对 |
| Y0, Y1 | output | 17 signed | 结果（两个 16 位乘积相加 → 17 位） |
| OUT_STROBE | output | 1 | Y0、Y1 有效时高一拍 |

总线顺序（每次运算 4 拍）：M00·X0 → M01·X1 → M10·X0 → M11·X1。之后连续运算，每 4 拍一组。

## 二、电路思路 + 代码逐段讲

**结构和 [08 三项点积](../08_三项点积/08_DotProduct3_讲解.md) 一样**（1 个乘法器 + 1 个累加器 + 计数器），只是 4 拍里要出**两个**结果：

| cnt | 总线 | 累加器 | 动作 |
|---|---|---|---|
| 0 | M00, X0 | 0 + M00·X0 | 新的一行，从 0 开始 |
| 1 | M01, X1 | + M01·X1 | 第 0 行结束 → 存进 `y0_tmp` |
| 2 | M10, X0 | 0 + M10·X0 | 新的一行，从 0 开始 |
| 3 | M11, X1 | + M11·X1 | 第 1 行结束 → Y0 ← y0_tmp，Y1 ← 和，OUT_STROBE = 1 |

```verilog
wire signed [16:0] base = (cnt == 0 || cnt == 2) ? 0 : acc;   // 每行开头清零
wire signed [16:0] sum  = base + {p[15], p};                   // 符号扩展
...
if (cnt == 1) y0_tmp <= sum;
if (cnt == 3) begin Y0 <= y0_tmp; Y1 <= sum; OUT_STROBE <= 1; end
```

- **为什么要 `y0_tmp`**：Y0 在第 1 拍就算好了，但题目要求 Y0、Y1 同时有效，所以先存起来，第 3 拍一起输出
- `cnt` 是 2 位，3 + 1 自动回到 0，不用写判断
- 例：[2 3; 4 5] × [10; 1] = [23; 45]（tb 的定向用例）

**变体：**3×3 矩阵乘向量：cnt 数到 8，每 3 拍清一次累加器，位宽变成 16 + 2 = 18。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 运算之间不留空拍，START 只在最开始给一次
- 定向用例：单位矩阵、全 −128（最坏情况，结果 32768）、正负混合、[2 3; 4 5] × [10; 1]
- 再加 36 组随机，结果按顺序检查
- 故意把符号扩展改成补 0，tb 报 30 个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_MatVec2x2`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_MatVec2x2` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `MatVec2x2` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `MatVec2x2` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `MatVec2x2.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../MatVec2x2.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/MatVec2x2.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_MatVec2x2.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `MatVec2x2`，instance 写 `MatVec2x2_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_MatVec2x2
cd Test2_MatVec2x2
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_MatVec2x2/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit MatVec2x2.v MatVec2x2_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./MatVec2x2_tb.v ./MatVec2x2.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 40 operations, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `MatVec2x2_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、Y0、Y1（Signed Decimal）、cnt、acc、OUT_STROBE。每 4 拍一个 OUT_STROBE 脉冲。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_MatVec2x2/Synthesis
cp ../Behavioral/MatVec2x2.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/MatVec2x2/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/MatVec2x2.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/MatVec2x2.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_MatVec2x2/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `MatVec2x2` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_MatVec2x2/Synthesis/netlist/      # 要有 Syn_MatVec2x2.v  Syn_MatVec2x2.sdf  Syn_MatVec2x2.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_MatVec2x2/rtl
cp ../Synthesis/netlist/Syn_MatVec2x2.v ../Synthesis/netlist/Syn_MatVec2x2.sdf .
cp ../Behavioral/MatVec2x2_tb.v .
ls                      # 要有 Syn_MatVec2x2.v  Syn_MatVec2x2.sdf  MatVec2x2_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./MatVec2x2_tb.v ./Syn_MatVec2x2.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_MatVec2x2.v`（网表）**，不是 `MatVec2x2.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 40 operations, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_MatVec2x2/rtl/PowerAnalysis
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
read_verilog ../Syn_MatVec2x2.v
current_design MatVec2x2
link
read_saif -input ./inter.saif -instance MatVec2x2_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `MatVec2x2_tb/U1`）
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

**Q：为什么结果是 17 位？**
每个乘积 16 位，两个相加需要多 1 位：(−128)·(−128) × 2 = 32768 > 32767。

**Q：如果有两个乘法器，可以怎么改？**
两行并行算：一个乘法器算 Y0 的项，另一个算 Y1 的项，2 拍出结果，吞吐率翻倍，面积也翻倍。这是面积和速度的权衡。

**Q：X0、X1 在总线上送了两遍，能省吗？**
可以先把 X0、X1 存进寄存器，后面只送矩阵元素。代价是多两个 8 位寄存器，好处是总线占用少。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：21 位串行比较器（高位先到）](../21_位串行比较器/21_SerialComparator_讲解.md) ｜ [下一题：23 8 个数求和、求平均](../23_求和与平均值/23_SumAvg_讲解.md)
