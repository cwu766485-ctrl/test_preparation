# NM6008 两文件 RTL + TB 模板（先用这版）

## 0. 这两个文件实现什么？
`ExamDUT.v` 为 8-bit 无符号寄存加法器：NRST=0 异步清零；当 START 在 CLK 上升沿为 1 时锁存 A+B（9 bits）并使 DONE 高 1 个周期；否则 RESULT 保持、DONE=0。

`tb_ExamDUT.sv` 为自动检查的 TB：定义端口 → 例化 DUT → 产生 100ns 时钟 → task(check/reset/test) → Gate-Level SDF → 保存 VPD → initial(reset/测试/总结) → timeout。

## 1. 考试拿到新题只改哪里？
- RTL：EDIT-RTL-1 端口；EDIT-RTL-2 内部状态/计数；EDIT-RTL-3 reset/时序；EDIT-RTL-4 运算逻辑。
- TB：EDIT-TB-1 信号；EDIT-TB-2 实例连接；EDIT-TB-3 频率；EDIT-TB-4 reset；EDIT-TB-5 独立参考模型和等待拍数；EDIT-TB-6 SDF 名称；EDIT-TB-7 测例。
- 如果是纯组合电路，RTL 可改为 `assign RESULT = ...;`，TB 移除 reset/clock 的依赖，task 改为“驱动 -> 等传播延时 -> 检查”。别把这个时序加法器模板不改就当作组合电路。
- 如果题目没有 DONE，必须从 RTL/TB 中移除；如果 DONE 不是同一拍有效，TB 的检查时刻也必须改。不能只替换表达式。

## 2. Behavioral Simulation (Module3 P8)
在行为仿真目录加载原实验的 VCS P-2019 csh 环境，然后：

```bash
vcs -full64 -sverilog -debug_access+all ./tb_ExamDUT.sv ./ExamDUT.v -o simv_rtl -l compile_rtl.log
./simv_rtl -l sim_rtl.log
dve -vpd inter.vpd &
```

`./simv -gui` 是交互式仿真，`./simv -l sim.log` 是存日志；是否产生 VPD 由 TB 中 `$vcdplusfile/$vcdpluson` 决定。也可以不同仿真模式用不同工作目录，避免覆盖 inter.vpd。

## 3. Gate-Level Simulation (Module3 P16–18)
先用 Design Compiler 综合，得到 **完整** `Syn_ExamDUT.v` 与 `Syn_ExamDUT.sdf`，并准备好 GF22 标准单元 `library.f`，将其放到 Gate 仿真工作目录。然后（注意以下命令需在该工作目录执行）：

```bash
vcs -full64 -sverilog -debug_access+all +neg_tchk -timescale=1ns/1ps \
  +define+GATE_SIM ./tb_ExamDUT.sv ./Syn_ExamDUT.v \
  -f ./library.f -o simv_gate -l compile_gate.log
./simv_gate -l sim_gate.log
dve -vpd inter.vpd &
```

注意：SDF 注释成功、没有缺失的单元模型，才可把门级测试判为有效。不要混用旧版 `simv.daidir`。最好在独立 Gate 工作目录跑。

## 4. 功耗分析 (Module3 P19–20)

```bash
vpd2vcd inter.vpd inter.vcd
vcd2saif -i inter.vcd -o inter.saif
```

在已加载 GF22 库的 `dc_shell-xg-t` 中：

```tcl
read_verilog ./Syn_ExamDUT.v
current_design ExamDUT
link
create_clock -name CLK -period 100 [get_ports CLK]
read_saif -input ./inter.saif -instance tb_ExamDUT/dut
report_saif -hierarchy
report_saif -missing
report_power > power.rpt
```

**强制先核对** `read_saif` 和 `report_saif` 的活动匹配情况。不要因 `report_power` 有数值就认为功耗有效。

## 5. 手册提醒
- Module3 P17 需要 `timescale`、`$sdf_annotate`、`$vcdpluson/off`；本 TB 都放在固定位置。
- `library.f` 中必须使用实际 GF22 工艺 Verilog 模型路径，不可直接用 `.db` 代替。
- 此包为独立示例，尚未在学校的 Synopsys 环境回归，不可将静态结构检查当作 Gate-Level 签核。
