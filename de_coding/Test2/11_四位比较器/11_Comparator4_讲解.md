# 11 · 4 位比较器（GT / EQ / LT）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[Comparator4.v](Comparator4.v) · [Comparator4_tb.v](Comparator4_tb.v)
> 复习优先级：★☆☆ ｜ 对应：组合逻辑 ｜ 上机预计：约 40 分钟

## 一、题目可能怎么出

**可能的题面：**"设计一个 4 位无符号数比较器，输出 A>B、A=B、A<B 三个信号"。变体：有符号比较、8 位比较、两个 4 位比较器级联。

## 二、电路思路 + 代码逐段讲

```verilog
assign GT = (A >  B);
assign EQ = (A == B);
assign LT = (A <  B);
```

就三行，重点在笔试会问**门级怎么实现**：

- 先算每一位是否相等：xᵢ = XNOR(Aᵢ, Bᵢ)
- EQ = x₃ · x₂ · x₁ · x₀
- GT：从最高位往下看，第一位不同的地方 A 是 1、B 是 0：
  GT = A₃B₃' + x₃A₂B₂' + x₃x₂A₁B₁' + x₃x₂x₁A₀B₀'
- LT = 把 GT 里的 A、B 对调；或者 LT = (GT 和 EQ 都不是 1)

**有符号比较：**端口声明成 `input wire signed [3:0] A`，或者写 `$signed(A) > $signed(B)`。例如 4 位有符号的 `1000` 是 −8，比 `0111`（+7）小；无符号时 8 > 7。

## 三、testbench 怎么工作

所有题的 testbench 都是同一个模板（和 [上机操作清单附录 B](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 一致）：
- DUT 实例名固定叫 **U1**（`$sdf_annotate` 和功耗的 `read_saif -instance` 都靠它）
- `` `ifdef GATE_SIM `` 里放 `$sdf_annotate`：同一个 tb，行为仿真不加 `+define+GATE_SIM`，门级仿真加
- `` `ifdef VCS `` 里放 `$vcdplusfile("inter.vpd")` / `$vcdpluson`：编译时加 `+define+VCS` 就会记录波形给功耗分析用
- 结果同时打印到终端和 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过
- 时序电路：**下降沿改输入、上升沿后 2 ns 检查输出**，行为仿真和门级仿真都不会有竞争

本题特有的：

- 两层循环穷举 16 × 16 = 256 种组合
- 期望值直接用整数比较 `(a > b)`

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_Comparator4`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。题目要求设计一个数字发生器，连续产生 4 个数字以寻找可打开继电器的秘密码。每个数字用 3 位二进制表示，取值 v∈{0,1,…,7}。
秘密码预设为四位值 v1v2v3v4。如果 Mi 产生的数字等于对应的 vi，Mi 就向逻辑模块输出 oi=1。四位全部匹配时继电器才打开。注意：Mi 无法直接读取完整的输入密码。
本电路的主要目标是依次产生与秘密码匹配的 4 个数字。
module Comparator (
    input  wire [2:0] A,
    input  wire [2:0] B,
    output wire       EQ,
);
    assign EQ = (A == B);

    // EQ 等于各位 A[i] 与 B[i] 同或结果的逻辑与。
endmodule

module Test2 (
    input  wire [2:0] A1, A2, A3, A4,
    //input  wire [2:0] v1, v2, v3, v4,
    output wire open,
);
    wire [3:0] o; 

    assign [2:0] v1 = 0;
    assign [2:0] v2 = 1;
    assign [2:0] v3 = 0;
    assign [2:0] v4 = 7;

    Comparator M1 (.A(A1), .B(v1), .EQ(o[0]));
    Comparator M2 (.A(A2), .B(v2), .EQ(o[1]));
    Comparator M3 (.A(A3), .B(v3), .EQ(o[2]));
    Comparator M4 (.A(A4), .B(v4), .EQ(o[3]));

    if (o[0]=1 && o[1]=1 && o[2]=1 && o[3]=1)
    open = 1;
	else 
	open = 0;

endmodule

请指出以下 Verilog 代码的问题并说明如何修改，同时为其编写 testbench。按我的学生 ID，测试密码为 0107。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module3` | `Test2_Comparator4` |
| RTL 里的 `module` 名 | `FullAdder` | `Comparator4` |
| `scripts/FullAdder.tcl` 里的顶层名（第 10、12 行） | `FullAdder` | `Comparator4` |
| `scripts/FullAdder.tcl` 文件名 | `FullAdder.tcl` | `Comparator4.tcl` |
| `scripts/run_topdown.tcl` | `source .../FullAdder.tcl` | `source .../Comparator4.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/FullAdder.v` | `./sources/Comparator4.v`（每个文件一行） |
| `scripts/MyDefaults.con` | — | **不改**：组合电路没有时钟，时钟那几行保持注释（行首有 `#`） |
| tb 里 `$sdf_annotate` | — | `Syn_Comparator4.sdf`（已写好） |
| 功耗 `pa.tcl` | `FullAdder` | `Comparator4`，instance 写 `Comparator4_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）
请根据此 testbench 写出正确的 Verilog 代码。
在 Linux 文件管理器进入 `~/NM6008`，选中整个 `Module3` 文件夹 → **Ctrl+C → Ctrl+V** → 将新副本重命名为 `Test2_Comparator4`。如果已经有可用的练习副本，就直接使用它；后续终端路径中的工程名相应替换。

> 如果你的 Module3 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_Comparator4/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit Comparator4.v Comparator4_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./Test2_tb.v ./Test2.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 256 combinations, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `Comparator4_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B（Unsigned）和 GT、EQ、LT，任意时刻三者只有一个为 1。

### 第 2 步：综合（终端 T2）

**2.1 用文件管理器放 RTL、改脚本名字：**同时打开本工程的 `Behavioral/` 和 `Synthesis/sources/`，从前者选中 `Comparator4.v` → **Ctrl+C** → 到后者 **Ctrl+V**；tb 不复制。若询问替换，核对是否为 T1 通过的新版。

再打开 `Synthesis/scripts/`，将 `FullAdder.tcl` 在文件管理器中重命名为 `Comparator4.tcl`。用 gedit 修改其中的顶层设计名，并修改 `ReadVerilogFiles.tcl`（每个设计 `.v` 一行 `read_verilog`）和 `run_topdown.tcl`（引用新的顶层 Tcl）。**不要在终端批量替换所有旧字符串**：旧名字可能仍是本题用到的子模块，例如 `FullAdder.v`。

`cat` 出来应该是：`read_verilog ./sources/Comparator4.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

组合电路：这几行**前面有 `#`（被注释）是对的**，保持不动。综合时出现和 clock 有关的 error/warning 可以忽略（手册 Note 1）。
如果你是从 Module5 复制的（行首没有 `#`），`gedit scripts/MyDefaults.con &`，在 `create_clock`、`set_clock_uncertainty`、`set_input_delay`、`set_output_delay` 这几行前面加 `#`。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_Comparator4/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `Comparator4` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_Comparator4/Synthesis/netlist/      # 要有 Syn_Comparator4.v 和 Syn_Comparator4.sdf；.sdc 若生成可归档
```

### 第 3 步：门级仿真（T3）

在 Linux 文件管理器里，把本次 `Synthesis/netlist/` 的 `Syn_Comparator4.v`、`Syn_Comparator4.sdf` 一起复制到 `rtl/`；再从 `Behavioral/` 把 `Comparator4_tb.v` 复制到 `rtl/`。若出现同名文件，核对新文件的修改时间后选择替换；保留 `rtl/library.f`。随后在 `rtl/` 打开终端：

```csh
ls                      # 要有 Syn_Comparator4.v  Syn_Comparator4.sdf  Comparator4_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./Comparator4_tb.v ./Syn_Comparator4.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_Comparator4.v`（网表）**，不是 `Comparator4.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 256 combinations, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_Comparator4/rtl/PowerAnalysis
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
read_verilog ../Syn_Comparator4.v
current_design Comparator4
link
read_saif -input ./inter.saif -instance Comparator4_tb/U1
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

- 只有 `pa.tcl` 执行了 `report_saif > rpt_saif.txt` 才会生成这份文件。检查活动是否映射到 DUT；覆盖率不到 100% 不一定是错误，需核对 `-instance`（本题为 `Comparator4_tb/U1`）、VPD 是否记录 DUT、网表是否对应及测试范围。
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

**Q：`A > B` 综合出来是什么？**
综合工具会用减法器的借位或者专门的比较器结构，在原理图和 `report_cell` 里能看到。

**Q：有符号和无符号比较结果什么时候不同？**
最高位不同时。例如 A=1000、B=0111：无符号 8>7，GT=1；有符号 −8<7，GT=0。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：10 4 位 ALU（加 / 减 / 与 / 或）](../10_四位算术逻辑单元/10_ALU4_讲解.md) ｜ [下一题：12 4 选 1 多路选择器（Mux4）](../12_四选一多路选择器/12_Mux4_讲解.md)
