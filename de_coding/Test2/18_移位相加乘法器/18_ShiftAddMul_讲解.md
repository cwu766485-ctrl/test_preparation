# 18 · 移位相加乘法器（8×8 无符号）

> **机房文件复制请用 [鼠标复制版四阶段步骤](../00_机房四阶段_鼠标复制版.md)**：Linux 文件管理器选文件 → Ctrl+C → 到目标文件夹 Ctrl+V。下方旧 `cp` 命令只是等价写法；终端只需执行仿真、综合和功耗工具。

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹的代码：[ShiftAddMul.v](ShiftAddMul.v) · [ShiftAddMul_tb.v](ShiftAddMul_tb.v)
> 复习优先级：★★☆ ｜ 对应：和 17 同类：1 个加法器 + 移位寄存器 + 计数器控制 ｜ 上机预计：约 75 分钟

## 一、题目可能怎么出

**可能的题面：**"用一个加法器、通过移位相加的方法实现 8 位乘法器"，或"把 Module 5 的组合乘法器换成时序（多周期）乘法器"。和 17 题是同一类：**少量运算单元 + 寄存器 + 计数器/FSM 控制，多个周期完成**。

| 端口 | 方向 | 位宽 | 作用 |
|---|---|---|---|
| CLK, NRST | input | 1 | 时钟、异步复位 |
| START | input | 1 | IDLE 时为 1：锁存 A、B，开始（忙时忽略） |
| A, B | input | 8 | 无符号乘数 |
| P | output | 16 | 乘积 |
| DONE | output | 1 | P 有效时高一拍 |

时序：START 沿装载 → 8 个沿各处理 B 的一位 → 下一拍 DONE。共 **W+1 = 9** 个周期。

## 二、电路思路 + 代码逐段讲

**原理就是二进制竖式乘法：**B 的第 i 位是 1，就把 A 左移 i 位加到结果上。

例：13 × 11（1101 × 1011，取 4 位方便看）

| 拍 | b_sh[0]（B 的第 i 位） | a_sh（A << i） | acc |
|---|---|---|---|
| 1 | 1 | 1101 | 0 + 1101 = 13 |
| 2 | 1 | 11010 | 13 + 26 = 39 |
| 3 | 0 | 110100 | 39（不加） |
| 4 | 1 | 1101000 | 39 + 104 = **143** ✔ |

**代码要点：**

```verilog
wire [2*W-1:0] acc_next = acc + (b_sh[0] ? a_sh : 0);   // 唯一的加法器

IDLE: if (START) begin
    a_sh <= {{W{1'b0}}, A};   // A 零扩展到 16 位（左移时高位才有地方放）
    b_sh <= B;  acc <= 0;  cnt <= 0;  state <= RUN;
end
RUN: begin
    acc  <= acc_next;
    a_sh <= a_sh << 1;        // 下一拍乘的是 A << (i+1)
    b_sh <= b_sh >> 1;        // 下一位移到 b_sh[0]
    if (cnt == W-1) begin P <= acc_next; DONE <= 1; state <= IDLE; end
    else cnt <= cnt + 1;
end
```

- `{{W{1'b0}}, A}`：复制拼接，前面补 8 个 0
- 最后一拍要用 `acc_next`（加完最后一项的值）给 P，不能用 `acc`（还没加最后一项）
- **和 Module 5 的 `$signed(A) * $signed(B)` 对比**：那个综合成一整块组合乘法器（DesignWare），1 拍出结果但面积大；这个只用一个 16 位加法器，面积小但要 8 拍

**常见变体：**
- 改位宽：只改 `parameter W`
- **有符号**乘法：简单办法是先取绝对值相乘，最后根据 A[7]^B[7] 决定结果取负；正规方法是 Booth 算法
- 优化版：乘积寄存器右移、A 不动（只需要 W 位加法器），是教科书上更省面积的写法

## 三、testbench 怎么工作

和其他题的 testbench 是同一个模板：DUT 实例名 **U1**；`` `ifdef GATE_SIM `` 里放 `$sdf_annotate`，`` `ifdef VCS `` 里放 `$vcdplusfile`/`$vcdpluson`；**下降沿改输入**；结果写进 `Check.txt`，最后一行 `==== DONE: ... 0 errors ====` 就是通过。

本题特有的：

- task `run_mul(a, b)`：给输入 → 等 DONE → 和 `a * b` 比较，并检查 DONE 正好在第 W+1 = 9 个时钟
- 先测边界：0、1、255、2 的幂、交替位（170 × 85）
- 默认再测 300 组随机数；编译时加 `+define+FULL` 会**穷举全部 65536 组**（行为仿真里约 1 秒；门级仿真会慢很多，不建议）
- 故意把 `a_sh <= a_sh << 1` 改成不移位，tb 报 303 个 FAIL

## 四、上机步骤（照着敲就行）

> 下面的命令已经把名字换好了，**整段复制**即可。
> 练习用的文件夹叫 `~/NM6008/Test2_ShiftAddMul`；考试时换成老师要求的文件夹名。
> 完整的原理和报错速查见 [上机操作清单](<../../NM6008 上机操作清单（Test 2 照着做）.md>) 和 [前端设计流程学习手册](<../../NM6008 前端设计流程学习手册（Module 3–5）.md>)。

> [!tip] 代码怎么放进机房电脑
> 在 Mac 上打开本文件夹里的 `.v` 文件 → 全选复制 → 切到 TigerVNC → 在机房的 gedit 里粘贴 → **Ctrl+S 保存**。
> VNC 里打不出 `_` 和 `/` 时：先在 Mac 上复制命令，切到别的 App 再切回 TigerVNC，在终端里按 **Ctrl+Shift+V** 粘贴。

### 先看：这道题要改的名字一览

| 位置 | 原来（复制来的） | 改成 |
|---|---|---|
| 复制哪个工程 | `Module5` | `Test2_ShiftAddMul` |
| RTL 里的 `module` 名 | `MatrixMultiplier` | `ShiftAddMul` |
| `scripts/MatrixMultiplier.tcl` 里的顶层名（第 10、12 行） | `MatrixMultiplier` | `ShiftAddMul` |
| `scripts/MatrixMultiplier.tcl` 文件名 | `MatrixMultiplier.tcl` | `ShiftAddMul.tcl` |
| `scripts/run_topdown.tcl` | `source .../MatrixMultiplier.tcl` | `source .../ShiftAddMul.tcl` |
| `scripts/ReadVerilogFiles.tcl` | `read_verilog ./sources/MatrixMultiplier.v` | `./sources/ShiftAddMul.v`（每个文件一行） |
| `scripts/MyDefaults.con` | `CLK_PERIOD` | 必须 = **20**（= tb 里的 2×CLK_T） |
| tb 里 `$sdf_annotate` | — | `Syn_ShiftAddMul.sdf`（已写好） |
| 功耗 `pa.tcl` | `MatrixMultiplier` | `ShiftAddMul`，instance 写 `ShiftAddMul_tb/U1` |

### 第 0 步：建练习文件夹（随便一个终端）

```csh
cd ~/NM6008
cp -r Module5 Test2_ShiftAddMul
cd Test2_ShiftAddMul
ls                      # 应看到 Behavioral  Synthesis  rtl ...
```

> 如果你的 Module5 里文件夹叫 `RTL`（大写），下面所有 `rtl` 都换成 `RTL`。先 `ls` 看清楚。

旧结果可以留在练习副本里；重新运行后核对新结果的文件名与修改时间。确实要整理时，先关工具并确认路径，只用 `/usr/bin/trash` 把选中的旧产物移入废纸篓；如果无法移入就停止清理。保留 `Library/`、`Synthesis/scripts/`、`sources/`、`netlist/`、`logs/`、`ddc/`、`rtl/PowerAnalysis/` 这些目录。

### 第 1 步：放代码 + 行为仿真（终端 T1）

开 T1（桌面右键 → Open Terminal）：

```csh
cd ~/NM6008/Test2_ShiftAddMul/Behavioral
csh
source synopsys_linux_vP_2019_cshrc
gedit ShiftAddMul.v ShiftAddMul_tb.v &
```

gedit 会打开 2 个标签页，把本文件夹里同名文件的内容分别粘贴进去，保存。然后编译、运行：

```csh
vcs -debug +v2k +define+VCS ./ShiftAddMul_tb.v ./ShiftAddMul.v -l compile_beh.log
./simv | tee sim_beh.log
cat Check.txt
```

**看到这行就对了：** `==== DONE: 312 multiplications, 0 errors ====`

- 编译报 `Error-[...]`：看报错里的**文件名和行号**，回 gedit 改 → 保存 → 再敲一遍 `vcs`
- `+define+VCS` 打开 tb 里记录波形的 `$vcdpluson`（第 3、4 步要用）
- 不加 `+define+GATE_SIM` = 行为仿真，tb 不会去读 SDF

看波形（要截图时）：

```csh
simv -gui &              # 报 command not found 就用 ./simv -gui &
```

DVE：左边点 `ShiftAddMul_tb` → 中间 Ctrl+A → 右键 **Add To Waves → New Wave View** → **Simulator → Start/Continue** → **View → Zoom → Zoom Full**。
重点看：A、B、a_sh、b_sh（Binary）、acc、P（Unsigned）、cnt、DONE。每拍 a_sh 左移、b_sh 右移，b_sh[0]=1 的那拍 acc 加上 a_sh。

### 第 2 步：综合（终端 T2）

**2.1 放 RTL、改脚本名字**（可以在 T1 里敲，不需要 source）：

```csh
cd ~/NM6008/Test2_ShiftAddMul/Synthesis
cp ../Behavioral/ShiftAddMul.v sources/
ls sources/ scripts/
grep -rn "MatrixMultiplier" scripts/          # 看旧名字出现在哪
sed -i 's/MatrixMultiplier/ShiftAddMul/g' scripts/ReadVerilogFiles.tcl scripts/MatrixMultiplier.tcl scripts/run_topdown.tcl
mv scripts/MatrixMultiplier.tcl scripts/ShiftAddMul.tcl
grep -rn "MatrixMultiplier" scripts/          # 这次应该什么都不输出
cat scripts/ReadVerilogFiles.tcl
```

`cat` 出来应该是：`read_verilog ./sources/ShiftAddMul.v`

**2.2 检查约束 MyDefaults.con：**

```csh
grep -n -E "CLK_PERIOD|create_clock|uncertainty|input_delay|output_delay" scripts/MyDefaults.con
```

时序电路：这几行**前面不能有 `#`**，并且 `CLK_PERIOD` = **20**。不对就 `gedit scripts/MyDefaults.con &` 改。
tb 里 `parameter CLK_T = 10;` → 时钟周期 2×10 = 20 ns，两边必须一致。

**2.3 开 T2，跑综合：**

```csh
cd ~/NM6008/Test2_ShiftAddMul/Synthesis
csh
source synopsys_linux_vR_2020_cshrc
design_vision &
```

1. **File → Execute Script** → 进 `scripts` → 选 **`run_topdown.tcl`** → Open
2. 等到最后出现 `design_vision>` 提示符，往上翻找 `Error`
3. 左边 **Logical Hierarchy** 右键 `ShiftAddMul` → **Schematic View**（截图）

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
ls ~/NM6008/Test2_ShiftAddMul/Synthesis/netlist/      # 要有 Syn_ShiftAddMul.v  Syn_ShiftAddMul.sdf  Syn_ShiftAddMul.sdc
```

### 第 3 步：门级仿真（终端 T3）

```csh
cd ~/NM6008/Test2_ShiftAddMul/rtl
cp ../Synthesis/netlist/Syn_ShiftAddMul.v ../Synthesis/netlist/Syn_ShiftAddMul.sdf .
cp ../Behavioral/ShiftAddMul_tb.v .
ls                      # 要有 Syn_ShiftAddMul.v  Syn_ShiftAddMul.sdf  ShiftAddMul_tb.v  library.f
csh
source synopsys_linux_vP_2019_cshrc
vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./ShiftAddMul_tb.v ./Syn_ShiftAddMul.v -f ./library.f -l compile_gate.log
./simv -l sim_gate.log
grep -i -E "sdf|annotat" compile_gate.log sim_gate.log
cat Check.txt
ls -l inter.vpd          # 第 4 步要用
```

- 编译的是 **`Syn_ShiftAddMul.v`（网表）**，不是 `ShiftAddMul.v`
- `+define+GATE_SIM` 打开 tb 里的 `$sdf_annotate`；`+neg_tchk` 防止 `SDFCOM_NNTC` 报错；64 位报错加 `-full64`
- SDF 反标要 **Total errors: 0**；`SDFCOM_CFTC`（cannot find timing check）警告可以忽略
- **结果要和行为仿真一样**：`==== DONE: 312 multiplications, 0 errors ====`

### 第 4 步：功耗分析（终端 T4）

```csh
cd ~/NM6008/Test2_ShiftAddMul/rtl/PowerAnalysis
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
read_verilog ../Syn_ShiftAddMul.v
current_design ShiftAddMul
link
read_saif -input ./inter.saif -instance ShiftAddMul_tb/U1
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

- `rpt_saif.txt` 里 nets/ports/pins 都是 **100 % user annotated**；不到 100 % → `-instance` 写错了（必须是 `ShiftAddMul_tb/U1`）
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

**Q：W 位移位相加乘法器需要几个周期？用几个加法器？**
W 个周期（加上装载 1 拍），1 个 2W 位加法器。对比组合乘法器：1 个周期，但需要约 W 个加法器的面积（阵列乘法器）。

**Q：乘积为什么是 2W 位？**
最大 (2^W − 1)² < 2^(2W)，8 × 8 最大 255 × 255 = 65025 < 65536，16 位刚好放得下。

**Q：怎么提前结束（加速）？**
如果 b_sh 已经全 0，后面不会再加东西，可以直接结束：`if (b_sh[W-1:1] == 0)`。代价是周期数不固定。

**Q：这和 Module 5 的乘法器、累加器有什么联系？**
Module 5 = 组合乘法器 + 累加器 + FSM；这题把乘法本身也拆成"累加 W 次"。两者都是**数据通路 + 控制器**的结构。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：17 n 位串行加法器（可变 n，往年 Test 2 原题）](../17_可变位宽串行加法器/17_SerialAdder_讲解.md) ｜ [下一题：19 位串行加/减法器（教科书版串行加法器）](../19_位串行加减法器/19_BitSerialAddSub_讲解.md)
