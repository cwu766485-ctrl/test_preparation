# 16 · 改错题（给一段有 bug 的代码，找错、改对）

> [← 返回总览](../00_Test2_总览.md) ｜ 本文件夹：6 个带 bug 的设计 `BugN_*.v` + 对应的 testbench（就是 01–13 题里用过的同一个 tb）
> 复习优先级：★★★（"修改 RTL"类上机题，笔试也可能出纸面版）｜ 每题 10–15 分钟

## 怎么练

1. **先不运行**：打开 `BugN_*.v`，对着文件开头的 Spec 读代码，试着自己找出 bug（这就是笔试的形式）
2. **再仿真**：用下表的命令跑，看 FAIL 信息是否和你的猜测一致
3. **改代码** → 重新编译 → 要看到 `0 errors`
4. 最后展开答案对照

| 题 | 设计文件 | 配哪个 tb | 原题（正确版本） |
|---|---|---|---|
| Bug 1 | `Bug1_ShiftReg4.v` | `ShiftReg4_tb.v` | [13_ShiftReg4](../13_四位移位寄存器/13_ShiftReg4_讲解.md) |
| Bug 2 | `Bug2_Counter4.v` | `Counter4_tb.v` | [03_Counter4](../03_四位计数器/03_Counter4_讲解.md) |
| Bug 3 | `Bug3_Adder4.v` | `Adder4_tb.v` + `InputVector.txt` | [01_Adder4](../01_四位加法器/01_Adder4_讲解.md) |
| Bug 4 | `Bug4_MAC.v`（**两个** bug） | `MAC_tb.v` | [09_MAC](../09_乘累加器/09_MAC_讲解.md) |
| Bug 5 | `Bug5_Mux4.v` | `Mux4_tb.v` | [12_Mux4](../12_四选一多路选择器/12_Mux4_讲解.md) |
| Bug 6 | `Bug6_SeqDet101.v` | `SeqDet101_tb.v` | [02_SeqDet101_Moore](../02_101序列检测器_Moore型/02_SeqDet101_Moore_讲解.md) |

**机房命令**（只需要行为仿真，一个终端就够）：

```csh
mkdir -p ~/NM6008/Debug
cd ~/NM6008/Debug
csh
source ~/NM6008/Module5/Behavioral/synopsys_linux_vP_2019_cshrc    # 借用 Module5 的环境文件
gedit Bug1_ShiftReg4.v ShiftReg4_tb.v &                            # 粘贴两个文件、保存
vcs -debug +v2k ./ShiftReg4_tb.v ./Bug1_ShiftReg4.v -l compile.log
./simv
```

换题时只改最后两行的文件名，例如 Bug 3：`vcs -debug +v2k ./Adder4_tb.v ./Bug3_Adder4.v`（Adder4 的 tb 还要同一个文件夹里有 `InputVector.txt`）。

> 每个 Bug 文件里的模块名和原题一样（`ShiftReg4`、`Counter4`……），所以能直接用原题的 tb。注意同一次编译**不要同时放进正确版和 Bug 版**，否则会报模块重复定义。

---

## 找 bug 的通用顺序（考场上照这个查）

1. **编译报错**：看 `Error-[...]` 给的文件名和行号。常见：分号、`begin/end` 不配对、在 `always` 里给 `wire` 赋值（要改成 `reg`）、在 `assign` 里给 `reg` 赋值
2. **编译 warning 也要看**：`port size mismatch`（位宽不匹配）、`implicit wire`（名字拼错，自动生成了 1 位的线）
3. **复位**：异步复位有没有写进敏感列表？复位时所有寄存器都清零了吗？
4. **赋值**：时序块用 `<=`，组合块用 `=`
5. **组合块完整性**：每个分支都给每个输出赋值了吗？`case` 有 `default` 吗？（否则 latch）
6. **敏感列表**：组合块读到的信号都列了吗？（直接改成 `@(*)`）
7. **位宽和符号**：结果放得下吗？有符号运算两边都 `$signed` 了吗？扩展补的是符号位还是 0？
8. **看波形**：找第一次出错的时刻，看当时哪个信号和预期不同，往前追

---

## Bug 1：移位寄存器

**仿真现象：**`FAIL ... Q=1111 expected 0001`：移一次以后 4 位全都等于 SIN。

> [!tip]- 提示
> 看 always 块里用的是哪种赋值符号，以及四行赋值的执行顺序。

> [!answer]- 答案
> **bug：时序块里用了阻塞赋值 `=`。**`Q[0] = SIN` 立刻生效，下一行 `Q[1] = Q[0]` 读到的已经是新值 SIN，依次传下去，四位全变成 SIN。
>
> **改法：**全部换成非阻塞 `<=`（复位那行也改）：
>
> ```verilog
> if (!NRST) Q <= 4'b0000;
> else if (EN) begin
>     Q[0] <= SIN;
>     Q[1] <= Q[0];
>     Q[2] <= Q[1];
>     Q[3] <= Q[2];
> end
> ```
>
> 或者一行写完：`Q <= {Q[2:0], SIN};`
>
> **另一种"碰巧对"的写法：**用 `=` 但倒过来写（先 Q[3] 后 Q[0]）也能仿真对，但这依赖书写顺序，容易出错，规范写法是时序块一律用 `<=`。

## Bug 2：计数器

**仿真现象：**大部分都 PASS，只有 `FAIL: async reset`。

> [!tip]- 提示
> Spec 说 NRST 是**异步**复位。异步的意思是什么？代码里哪里体现？

> [!answer]- 答案
> **bug：敏感列表里没有 `negedge NRST`**，复位变成了同步复位：NRST 拉低后要等到下一个时钟上升沿才清零。tb 在两个时钟沿之间拉低 NRST，2 ns 后检查 Q 还没清零。
>
> **改法：**
>
> ```verilog
> always @(posedge CLK or negedge NRST) begin
> ```
>
> **为什么容易漏：**功能上看起来都对（数数、清零都没问题），只有专门在时钟沿之间测复位才能发现。综合出来的触发器也不同：异步复位会用带复位端（RD/RN）的 FF，同步复位是普通 FF 前面加一个与门。

## Bug 3：4 位加法器

**仿真现象：**`A=8 B=8 CIN=0 -> COUT=0 S=0 (expected 16)`：只要结果 ≥ 16，COUT 就是 0。

> [!tip]- 提示
> `sum` 有几位？4 位的数最大能是多少？

> [!answer]- 答案
> **bug：位宽截断。**`sum` 只有 4 位，`A + B + CIN` 的第 5 位（进位）在赋值时被丢掉了。4 位数最大 15，`sum > 15` 永远为假，所以 COUT 永远是 0。
>
> **改法：**左边给 5 位，让进位有地方放：
>
> ```verilog
> assign {COUT, S} = A + B + CIN;
> ```
>
> 或者 `wire [4:0] sum = A + B + CIN; assign S = sum[3:0]; assign COUT = sum[4];`
>
> **规则：**Verilog 运算的结果位宽由**左边**决定，放不下的高位直接丢，不报错（最多一个 warning）。N 位 + N 位要 N+1 位；N 位 × N 位要 2N 位。

## Bug 4：有符号 MAC（两个 bug）

**仿真现象：**`FAIL ACC=12072 expected 11048` 等，A 或 B 是负数时结果就错。

> [!tip]- 提示
> 手算 A = −2、B = 3：`p` 应该是 −6 = `16'hFFFA`。
> ① 乘法两边的类型一样吗？② 16 位扩展到 20 位，高 4 位补的是什么？

> [!answer]- 答案
> **bug ①：B 没有 `$signed`。**表达式里只要有一个操作数是无符号，**整个表达式都按无符号算**，`$signed(A)` 也会被当成无符号：−2 被当成 254，254 × 3 = 762。
>
> **bug ②：零扩展。**`{4'b0000, p}` 给负数补 0，−6（`FFFA`）变成 `0FFFA` = +65530。有符号数要补符号位。
>
> **改法：**
>
> ```verilog
> wire signed [15:0] p     = $signed(A) * $signed(B);
> wire signed [19:0] p_ext = {{4{p[15]}}, p};      // 复制符号位 4 次
> ```
>
> （把端口 B 也声明成 `signed` 更规范。）**只改一个 bug，仿真还是会 FAIL**，两处都要改。

## Bug 5：4 选 1 MUX

**仿真现象：**`FAIL SEL=11 Y=6 expected c`：SEL = 11 时 Y 停在上一次的值。

> [!tip]- 提示
> SEL = 11 时，always 块里哪一行会执行？Y 被赋值了吗？

> [!answer]- 答案
> **bug：`if-else if` 链没有最后的 `else`，SEL = 11 时 Y 没被赋值**，只能保持上次的值。仿真里表现为"停在旧值"；**综合出来是一个 latch**，DC 的日志里会出现 `Inferred memory devices ... Latch`。
>
> **改法（任选一种）：**
>
> ```verilog
> else Y = D3;                    // 补上 else
> ```
>
> 或者在 always 块开头加一行默认值 `Y = 4'd0;`，或者改成带 `default` 的 `case`。
>
> **笔试常问：**这段代码综合出什么？→ latch，以及为什么（组合块里有分支没给输出赋值，需要记忆）。

## Bug 6："101" 检测器

**仿真现象：**`FAIL ... DIN=1 DET=0 expected 1`：一直检测不到 101。

> [!tip]- 提示
> 看次态逻辑那个 always 块的敏感列表。DIN 变化时这个块会执行吗？

> [!answer]- 答案
> **bug：敏感列表 `always @(state)` 漏了 DIN。**tb 在下降沿改 DIN，但 state 没变，所以 next_state 不会重新计算，用的还是旧 DIN 算出的值，状态机走错路。
>
> **改法：**
>
> ```verilog
> always @(state or DIN) begin      // 或者直接 always @(*)
> ```
>
> **综合后的网表有这个 bug 吗？没有。**综合工具不看敏感列表，照常根据代码生成组合逻辑（只给一个 warning）。所以这是**仿真和综合结果不一致**的典型例子：行为仿真 FAIL，门级仿真反而对了。这正是要用 `@(*)` 的原因。

---

## 纸面改错题（笔试可能出，没有配仿真文件）

**7.** testbench 里这样给输入，有什么问题？

```verilog
always @(posedge CLK) begin
    DIN <= stream[i];
    i = i + 1;
end
```

> [!answer]- 答案
> 在上升沿改输入，和 DUT 在同一个沿采样，**谁先执行不确定（竞争）**。门级仿真加上延时后结果还可能和行为仿真不同。应在 `@(negedge CLK)` 改输入，或者上升沿后加一点延时。

**8.** tb 这样写会怎样？

```verilog
reg [3:0] k;
initial for (k = 0; k < 16; k = k + 1) begin A = k; #10; end
```

> [!answer]- 答案
> **死循环。**k 只有 4 位，15 + 1 回绕成 0，`k < 16` 永远为真。循环变量用 `integer`，或者把 k 声明成 5 位。

**9.** 仿真一直不结束，tb 里有：

```verilog
always CLK = ~CLK;
```

> [!answer]- 答案
> 没有延时，CLK 在同一时刻无限翻转，仿真时间永远不前进（卡死）。应写 `always #10 CLK = ~CLK;`，并在最后调用 `$finish`。

**10.** 编译报 `Illegal reference to net "S"`：

```verilog
output S;
always @(*) S = A ^ B;
```

> [!answer]- 答案
> 在 always 块里赋值的信号必须是 `reg`：改成 `output reg S;`。反过来，`assign` 只能驱动 `wire`。

**11.** 门级仿真看不到任何延时，日志里有 `SDF Warning: instance DUT not found`。tb 里写的是：

```verilog
MatrixMultiplier U1 (...);
initial $sdf_annotate("Syn_MatrixMultiplier.sdf", DUT);
```

> [!answer]- 答案
> `$sdf_annotate` 第二个参数要写 **tb 里的实例名 U1**，不是随便的名字。延时没有反标进去，门级仿真就变成了零延时仿真。

**12.** 综合报 `Cannot find design 'Adder4'` / `Unable to resolve reference 'FullAdder'`。

> [!answer]- 答案
> 前者：`Adder4.tcl` 里的顶层名、`ReadVerilogFiles.tcl` 的文件名和 RTL 的 `module` 名不一致。后者：多文件设计，`ReadVerilogFiles.tcl` 里漏了 `read_verilog ./sources/FullAdder.v`。

**13.** 行为仿真全对，门级仿真有几组错。tb 时钟 `CLK_T = 5`（周期 10 ns），综合的 `CLK_PERIOD` 是 20。

> [!answer]- 答案
> 网表是按 20 ns 优化的，tb 用 10 ns 时钟跑，可能违反 setup，结果出错。**tb 时钟周期必须 = 综合时钟周期**（或者更慢）。

**14.** 功耗分析 `report_saif` 显示只有 0% user annotated，`pa.tcl` 里写的是 `read_saif -input inter.saif -instance U1`。

> [!answer]- 答案
> `-instance` 要写从 tb 顶层开始的完整路径：`X_tb/U1`。路径不对，工具找不到对应的翻转数据，只能用默认值。

---

[← 返回总览](../00_Test2_总览.md) ｜ [上一题：15 时钟分频器](../15_时钟分频器/15_ClkDiv_讲解.md) ｜ [下一题：17 串行加法器](../17_可变位宽串行加法器/17_SerialAdder_讲解.md)
