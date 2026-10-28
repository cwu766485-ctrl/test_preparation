# 09 · 乘累加器 MAC（ACC += A×B）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[MAC.v](MAC.v) · [MAC_tb.v](MAC_tb.v)
> 复习优先级：★★☆ ｜ 对应：Module 5 变体（AI 加速器的基本单元） ｜ 上机预计：约 50 分钟

## 一、题目可能怎么出

**可能的题面：**
- "设计一个乘累加单元：每个时钟 ACC = ACC + A×B，带同步清零 CLR 和使能 EN"。
- 变体：累加 N 次后自动输出（加计数器，就变成了 [08](../08_三项点积/08_DotProduct3_讲解.md)）。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| CLR | input | 1 | 同步清零（优先于 EN） |
| EN | input | 1 | 1 = 这一拍累加 |
| A, B | input | 8 signed | 乘数 |
| ACC | output | 20 signed | 累加结果 |

**位宽：**乘积 16 位 + 4 位保护位 = 20 位，最多可以连续累加 2⁴ = 16 个最坏情况的乘积（16 × 16384 = 262144 < 2¹⁹）不溢出。

## 二、电路思路 + 代码逐段讲

```verilog
wire signed [15:0] p     = $signed(A) * $signed(B);
wire signed [19:0] p_ext = {{4{p[15]}}, p};          // 符号扩展 16 → 20 位

always @(posedge CLK or negedge NRST)
    if (!NRST)       ACC <= 20'sd0;
    else if (CLR)    ACC <= 20'sd0;
    else if (EN)     ACC <= ACC + p_ext;
```

结构就是 [03 计数器](../03_四位计数器/03_Counter4_讲解.md) 把 `+1` 换成 `+A×B`：

```
A ─┐
   ×──► p ──► 符号扩展 ──► (+) ──► ACC 寄存器 ──┬──► ACC
B ─┘                        ▲                    │
                            └────────────────────┘
```

- `20'sd0`：`s` 表示有符号常数，`d` 十进制
- 保护位（guard bits）的意义：累加很多次时结果会变大，多留几位防止溢出
- 关键路径：A/B → 乘法器 → 加法器 → ACC 的 D 端。用 `report_timing` 看

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- `A = $random(seed)`：伪随机数，固定 seed = 7，每次跑结果一样，方便复现
- `EN = ($random(seed) % 4) != 0`：大约 3/4 的周期使能
- `CLR` 每 10 拍给一次
- 参考模型直接用整数 `ref_acc <= ref_acc + A * B`
- 最后专门测最坏情况：连续 16 次 (−128)×(−128)，期望 ACC = 262144

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_MAC`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_MAC` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `MAC` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `MAC` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `MAC.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../MAC.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/MAC.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_MAC.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `MAC`，instance 写 `MAC_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_MAC
cd Test2_MAC
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_MAC/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit MAC.v MAC_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./MAC_tb.v ./MAC.v -l compile_beh.log
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

DVE：左边点 `MAC_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、ACC 设成 **Signed Decimal**，看 EN=0 时保持、CLR 后清零。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_MAC/Synthesis
cp ../Behavioral/MAC.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/MAC/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/MAC.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/MAC.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_MAC/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `MAC` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_MAC/Synthesis/netlist/      # 要有 Syn_MAC.v  Syn_MAC.sdf  Syn_MAC.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_MAC/rtl
cp ../Synthesis/netlist/Syn_MAC.v ../Synthesis/netlist/Syn_MAC.sdf .
cp ../Behavioral/MAC_tb.v .
ls                      # 要有 Syn_MAC.v  Syn_MAC.sdf  MAC_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./MAC_tb.v ./Syn_MAC.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_MAC.v`（网表）**，不是 `MAC.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_MAC/rtl/PowerAnalysis
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
read_verilog ../Syn_MAC.v
current_design MAC
link
read_saif -input ./inter.saif -instance MAC_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `MAC_tb/U1`）
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

**Q：为什么累加器要比乘积多几位？**
累加 K 次后结果最多是单个乘积的 K 倍，需要多 ⌈log₂K⌉ 位，否则溢出。

**Q：溢出了会怎样？怎么处理？**
二进制补码溢出后会"绕回"，大正数变成负数。处理方法：加宽位宽；或者用饱和运算（超过最大值就停在最大值）。

**Q：MAC 在哪里用？**
FIR 滤波器、矩阵乘法、卷积神经网络。AI 加速器里就是成千上万个 MAC 并行（脉动阵列 systolic array）。

**Q：怎么提高 MAC 的频率？**
在乘法器和加法器之间插一级流水寄存器（就像 Module 5 的 product_reg），关键路径减半，代价是多一拍延迟。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：08 三项点积 A2·B2 + A1·B1 + A0·B0](../08_三项点积/08_DotProduct3_讲解.md) ｜ [下一题：10 4 位 ALU（加 / 减 / 与 / 或）](../10_四位算术逻辑单元/10_ALU4_讲解.md)
