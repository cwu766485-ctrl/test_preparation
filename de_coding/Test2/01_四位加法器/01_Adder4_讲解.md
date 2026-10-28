# 01 · 4 位行波进位加法器（Adder4）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[Adder4.v](Adder4.v) · [FullAdder.v](FullAdder.v) · [Adder4_tb.v](Adder4_tb.v) · [InputVector.txt](InputVector.txt)
> 复习优先级：★★★ ｜ 对应：Module 3（组合逻辑 + 模块例化） ｜ 上机预计：约 60 分钟

## 一、题目可能怎么出

**可能的题面：**
- "用 Module 3 的全加器搭一个 4-bit 加法器，仿真、综合、做功耗分析。"
- 变体：8-bit 加法器（同样的方法例化 8 次，或者用 `generate`）、4-bit 减法器（B 取反 + CIN=1）。

**输入输出：**

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| A, B | input | 4 | 两个加数（无符号 0–15） |
| CIN | input | 1 | 最低位进位 |
| S | output | 4 | 和 |
| COUT | output | 1 | 最高位进位（结果 ≥ 16 时为 1） |

`{COUT, S} = A + B + CIN`，最大 15+15+1 = 31，正好 5 位。

## 二、电路思路 + 代码逐段讲

**思路：** 一个全加器算 1 位，把第 i 位的进位 COUT 接到第 i+1 位的 CIN，4 个串起来就是 4 位加法器。进位像波浪一样一位一位往上传，所以叫**行波进位（ripple carry）**。

```
 A0 B0 CIN      A1 B1          A2 B2          A3 B3
  │  │  │        │  │           │  │           │  │
 ┌┴──┴──┴┐ c0  ┌─┴──┴─┐ c1   ┌─┴──┴─┐ c2   ┌─┴──┴─┐
 │  FA0  ├────►│ FA1  ├─────►│ FA2  ├─────►│ FA3  ├──► COUT
 └───┬───┘     └──┬───┘      └──┬───┘      └──┬───┘
     S0           S1            S2            S3
```

**FullAdder.v**（和 Module 3 一样）：

```verilog
assign S    = A ^ B ^ CIN;                     // 三个数异或 = 和
assign COUT = (A & B) | (CIN & (A ^ B));       // 两个 1 以上就进位
```

**Adder4.v 关键部分：**

```verilog
wire [3:0] c;    // 每一位的进位输出，是模块内部的连线，所以用 wire
FullAdder FA0 (.A(A[0]), .B(B[0]), .CIN(CIN ), .S(S[0]), .COUT(c[0]));
FullAdder FA1 (.A(A[1]), .B(B[1]), .CIN(c[0]), .S(S[1]), .COUT(c[1]));
...
assign COUT = c[3];
```

- `FullAdder FA0 (...)`：**模块例化**。`FullAdder` 是模块名，`FA0` 是实例名（随便起，不能重复）
- `.A(A[0])`：**按名字连接**，点后面是子模块的端口名，括号里是这一层的信号。比按位置连接不容易接错
- 注释里还有一行写法 `assign {COUT, S} = A + B + CIN;`，也能综合，结果一样。题目如果要求"用全加器搭"，就用例化的写法

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- `reg [8:0] vec [0:255]`：一个"存储器"，每行 9 位 = `{A, B, CIN}`
- `$readmemb("InputVector.txt", vec)`：按**二进制**读文件，每行一个数；`_` 只是分隔符，`//` 后面是注释
- `{A, B, CIN} = vec[i];`：拼接赋值，一次把 9 位拆给三个信号
- 每组等 `#10`（10 ns）再比较，门延时只有几十 ps，足够稳定
- 期望值直接用 `A + B + CIN` 算（tb 不需要综合，可以随便用运算符）
- 想多测几组：在 `InputVector.txt` 里按同样格式加行。全部 512 种组合也可以用两层 for 循环直接生成，见 [10_ALU4](../10_四位算术逻辑单元/10_ALU4_讲解.md) 的写法

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_Adder4`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module3` | `Test2_Adder4` |
| RTL 里的 `module` 名 | `FullAdder` | `Adder4` |
| `scripts/FullAdder.tcl` 里的顶层名（第 10、12 行） | `FullAdder` | `Adder4` |
| `scripts/FullAdder.tcl` 文件名 | `FullAdder.tcl` | `Adder4.tcl` |
| `scripts/run_topdown.tcl` | `source .../FullAdder.tcl` | `source .../Adder4.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/FullAdder.v` | `./sources/Adder4.v` + `./sources/FullAdder.v`（每个文件一行） |
| `scripts/MyDefaults.con` | — | **不改**：组合电路没有时钟，时钟那几行保持注释（行首有 `#`） |
| tb 里 `$sdf_annotate` | — | `Syn_Adder4.sdf`（已写好） |
| 功耗 `pa.tcl` | `FullAdder` | `Adder4`，instance 写 `Adder4_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module3 Test2_Adder4
cd Test2_Adder4
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module3 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_Adder4/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit Adder4.v FullAdder.v Adder4_tb.v InputVector.txt &
```

gedit 会打开 4 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./Adder4_tb.v ./Adder4.v ./FullAdder.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 12 vectors, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `Adder4_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、CIN、S、COUT；把 A、B、S 设成 **Unsigned** 显示，对着 A+B+CIN 检查。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_Adder4/Synthesis
cp ../Behavioral/Adder4.v ../Behavioral/FullAdder.v sources/
ls sources/ scripts/
grep -rn "FullAdder" scripts/          # 看旧名字出现在哪
sed -i 's/FullAdder/Adder4/g' scripts/ReadVerilogFiles.tcl scripts/FullAdder.tcl scripts/run_topdown.tcl
mv scripts/FullAdder.tcl scripts/Adder4.tcl
grep -rn "FullAdder" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

> [!warning] 本题有 2 个 .v 文件，ReadVerilogFiles.tcl 要写 2 行
> `gedit scripts/ReadVerilogFiles.tcl &`，改成：
>
> ```tcl
> read_verilog ./sources/Adder4.v
> read_verilog ./sources/FullAdder.v
> ```
> 漏掉一个，综合时会报 `Cannot find design` / `Unable to resolve reference`。

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

组合电路：这几行**前面有 `#`（被注释）是对的**，保持不动。综合时出现和 clock 有关的 error/warning 可以忽略（手册 Note 1）。
如果你是从 Module5 复制的（行首没有 `#`），`gedit scripts/MyDefaults.con &`，在 `create_clock`、`set_clock_uncertainty`、`set_input_delay`、`set_output_delay` 这几行前面加 `#`。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_Adder4/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `Adder4` → **Schematic View**（截图）

**2.4 在 `design_vision>` 里查结果（答题用，结果截图或记下来）：**

```tcl
report_area
report_cell
report_timing -significant_digits 4            ;# 组合电路显示 (Path is unconstrained)，看 data arrival time
report_qor
report_constraint -all_violators
report_power
exit
```

检查产物：

```csh
ls ~/NM6008/Test2_Adder4/Synthesis/netlist/      # 要有 Syn_Adder4.v  Syn_Adder4.sdf  Syn_Adder4.sdc
```

> [!note] 综合结果长什么样
> 4 个 FullAdder 会被展开成门，大概是 XOR + AO22 之类的单元串成 4 级。关键路径是 **CIN（或 A0/B0）→ 进位一路传到 COUT**，这就是"行波进位"慢的原因。用 `report_timing -to COUT -significant_digits 4` 看。

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_Adder4/rtl
cp ../Synthesis/netlist/Syn_Adder4.v ../Synthesis/netlist/Syn_Adder4.sdf .
cp ../Behavioral/Adder4_tb.v ../Behavioral/InputVector.txt .
ls                      # 要有 Syn_Adder4.v  Syn_Adder4.sdf  Adder4_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./Adder4_tb.v ./Syn_Adder4.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_Adder4.v`（网表）**，不是 `Adder4.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 12 vectors, 0 errors ====`
- 门级仿真里输入变化后，S 和 COUT 会晚几十 ps 才变；tb 每组等 10 ns 再检查，所以不受影响。

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_Adder4/rtl/PowerAnalysis
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
read_verilog ../Syn_Adder4.v
current_design Adder4
link
read_saif -input ./inter.saif -instance Adder4_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `Adder4_tb/U1`）
- `link` 报 `Unable to resolve reference` → 库路径不对，回到 `common_setup_gf22.tcl`
- 记下 Internal / Switching / Leakage / Total，和第 2 步的 `report_power` 对比

### 结果记录表（考试时边做边填）

| 项目 | 结果 |
|---|---|
| 行为仿真 | __ errors |
| cell 数 / 面积 | |
| 用了哪些门（report_cell） | |
| 最大延时（data arrival time） | |
| 门级仿真 | __ errors，SDF errors = 0 |
| 功耗：合成估计 / SAIF 反标 | |

## 五、可能被问的问题（附答案）

**Q：行波进位加法器的缺点？怎么改进？**
延时随位数线性增长（N 位要等进位传 N 级）。改进：超前进位加法器（Carry Look-Ahead, CLA），用 G = A·B（生成）、P = A⊕B（传播）提前算出每一位的进位；或者进位选择（carry select）加法器。

**Q：关键路径是哪条？**
从 A0/B0/CIN 经过 4 级进位链到 COUT（或 S3）。

**Q：4 位加法器怎么改成减法器？**
A − B = A + (~B) + 1：把 B 每位取反，CIN 接 1。此时 COUT = 1 表示**没有借位**（A ≥ B）。

**Q：组合电路综合时为什么报 clock 相关的错？**
设计里没有时钟，约束文件里的时钟命令找不到对象。手册说这类可以忽略。时序报告会写 `(Path is unconstrained)`，只能看 data arrival time。

**Q：`.A(A[0])` 和 `FullAdder FA0 (A[0], B[0], ...)` 有什么区别？**
前者按名字连接，后者按端口顺序连接。按名字更安全，端口顺序改了也不会接错。

---

[← 返回总览](../00_Test2_总览.md) ｜ [下一题：02 "101" 序列检测器（Moore 型）](../02_101序列检测器_Moore型/02_SeqDet101_Moore_讲解.md)
