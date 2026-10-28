# 21 · 位串行比较器（高位先到）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[SerialComparator.v](SerialComparator.v) · [SerialComparator_tb.v](SerialComparator_tb.v)
> 复习优先级：★★☆ ｜ 对应：M4 状态机（3 个状态的 Moore FSM） ｜ 上机预计：约 45 分钟

## 一、题目可能怎么出

**可能的题面：**"两个 n 位无符号数从高位开始逐位串行输入，设计电路判断 A > B、A = B 还是 A < B"。

| 端口 | 方向 | 作用 |
|---|---|---|
| CLK, NRST | input | 时钟、异步复位 |
| FIRST | input | 和一个新字的**最高位**一起为 1 |
| A, B | input | 当前这一位（高位先到） |
| GT, EQ, LT | output | 到目前为止收到的高位部分的比较结果（Moore：时钟沿之后更新） |

最后一位的时钟沿过后，GT/EQ/LT 就是整个字的结果。

## 二、电路思路 + 代码逐段讲

**关键观察：从高位往低位比，第一个不同的位就决定了结果**，后面的位都不用看了。

**状态图（Moore，3 个状态）：**

| 当前状态 | A B = 10 | A B = 01 | A B = 00 或 11 |
|---|---|---|---|
| EQ（还没分出大小） | → GT | → LT | → EQ |
| GT（已确定 A 大） | GT | GT | GT |
| LT（已确定 A 小） | LT | LT | LT |

FIRST = 1 时不管当前状态，都按"EQ"那一行走（新的一个字从头比）。

```verilog
always @(*) begin
    if (FIRST || state == S_EQ) begin           // 还没分出大小，或者新字开始
        if (A & ~B)      next_state = S_GT;
        else if (~A & B) next_state = S_LT;
        else             next_state = S_EQ;
    end else
        next_state = state;                     // 已经确定，保持
end
assign GT = (state == S_GT);                    // Moore 输出：只看状态
```

**逐拍演示：0110 vs 0101**

| 拍 | A B | 下一状态 |
|---|---|---|
| 1（FIRST） | 0 0 | EQ |
| 2 | 1 1 | EQ |
| 3 | 1 0 | **GT** |
| 4 | 0 1 | GT（已确定，这一位不影响） |

**如果低位先到呢？**那就反过来：后到的位（更高位）优先级更高。每拍只要 A≠B 就用这一位覆盖结果，相等时保持。

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- 字和字之间不留空拍，长度 n 随机 1–16
- **每一位之后都检查**：GT/EQ/LT 必须等于"已经收到的高位部分"的比较结果，所以中间过程也测到了
- 三分之一的字 A = B，三分之一只在最后一位不同（最难的情况）
- 故意去掉 `FIRST ||`（新字不重新开始比较），tb 报上千个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_SerialComparator`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_SerialComparator` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `SerialComparator` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `SerialComparator` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `SerialComparator.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../SerialComparator.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/SerialComparator.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_SerialComparator.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `SerialComparator`，instance 写 `SerialComparator_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_SerialComparator
cd Test2_SerialComparator
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_SerialComparator/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit SerialComparator.v SerialComparator_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./SerialComparator_tb.v ./SerialComparator.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 150 words, 1258 bit checks, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `SerialComparator_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：FIRST、A、B、GT、EQ、LT。在第一个 A≠B 的位之后，GT 或 LT 变成 1，并一直保持到下一个 FIRST。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_SerialComparator/Synthesis
cp ../Behavioral/SerialComparator.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/SerialComparator/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/SerialComparator.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/SerialComparator.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_SerialComparator/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `SerialComparator` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_SerialComparator/Synthesis/netlist/      # 要有 Syn_SerialComparator.v  Syn_SerialComparator.sdf  Syn_SerialComparator.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_SerialComparator/rtl
cp ../Synthesis/netlist/Syn_SerialComparator.v ../Synthesis/netlist/Syn_SerialComparator.sdf .
cp ../Behavioral/SerialComparator_tb.v .
ls                      # 要有 Syn_SerialComparator.v  Syn_SerialComparator.sdf  SerialComparator_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./SerialComparator_tb.v ./Syn_SerialComparator.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_SerialComparator.v`（网表）**，不是 `SerialComparator.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 150 words, 1258 bit checks, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_SerialComparator/rtl/PowerAnalysis
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
read_verilog ../Syn_SerialComparator.v
current_design SerialComparator
link
read_saif -input ./inter.saif -instance SerialComparator_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `SerialComparator_tb/U1`）
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

**Q：为什么用 Moore 而不是 Mealy？**
结果只在时钟沿后变化，没有毛刺；代价是比 Mealy 晚一拍。用 Mealy 的话，最后一位还在输入线上时就能出结果。

**Q：3 个状态需要几个触发器？用 one-hot 呢？**
二进制编码 2 个（有一个编码没用到，靠 default 回到安全状态）；one-hot 3 个，输出直接就是触发器，最快。

**Q：有符号数（补码）怎么比？**
只有最高位（符号位）的判断要反过来：A 的符号位是 1、B 是 0 时 A 更小。之后的位和无符号一样。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：20 移位相减除法器（恢复余数法，8÷8）](../20_移位相减除法器/20_ShiftSubDiv_讲解.md) ｜ [下一题：22 2×2 矩阵乘向量（Module 5 扩展成两个输出）](../22_二乘二矩阵乘向量/22_MatVec2x2_讲解.md)
