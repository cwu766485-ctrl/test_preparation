# UVM 加法器测试平台示例

本示例验证 1 位半加器和 1 位全加器。

## UVM 数据流

sequence → sequencer → driver → interface → DUT
                                      │
                                      ↓
scoreboard ← analysis_port ← monitor

## 目录结构

~~~text
day3_uvm_adder/
├── Makefile
├── filelist.f
├── rtl/
│   └── adder.v
└── tb/
    ├── adder_if.sv
    ├── adder_pkg.sv
    ├── adder_item.sv
    ├── adder_sequence.sv
    ├── adder_driver.sv
    ├── adder_monitor.sv
    ├── adder_scoreboard.sv
    ├── adder_agent.sv
    ├── adder_env.sv
    ├── adder_test.sv
    └── tb_top.sv
~~~

## 使用 Synopsys VCS 运行

~~~sh
make clean
make run
~~~

检查结果：

~~~sh
grep -E "UVM_(ERROR|FATAL)|SB_REPORT" sim.log
~~~

预期记分板结果：

~~~text
PASS=8 FAIL=0
~~~

打开波形：

~~~sh
make verdi
~~~

建议观察以下信号：

~~~text
tb_top.clk
tb_top.vif.a
tb_top.vif.b
tb_top.vif.cin
tb_top.vif.half_sum
tb_top.vif.half_cout
tb_top.vif.full_sum
tb_top.vif.full_cout
~~~

## UVM 编码练习重点

常见的 UVM 小题包括 sequence_item/transaction、约束与随机化、sequence、driver、monitor、scoreboard/reference model、interface/clocking block、analysis_port/analysis_imp、SVA 和功能覆盖率。

从零编写完整 UVM 环境内容较多，通常不适合短时间手写题。
