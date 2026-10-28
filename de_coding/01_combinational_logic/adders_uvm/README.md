# Minimal UVM Adder Testbench

This package verifies both a 1-bit half adder and a 1-bit full adder.

## UVM data path

sequence -> sequencer -> driver -> interface -> DUT
                                      |
                                      v
scoreboard <- analysis_port <- monitor

## Directory

```text
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
```

## Run with Synopsys VCS

```bash
make clean
make run
```

Check result:

```bash
grep -E "UVM_(ERROR|FATAL)|SB_REPORT" sim.log
```

Expected scoreboard result:

```text
PASS=8 FAIL=0
```

Open waveform:

```bash
make verdi
```

Watch:

```text
tb_top.clk
tb_top.vif.a
tb_top.vif.b
tb_top.vif.cin
tb_top.vif.half_sum
tb_top.vif.half_cout
tb_top.vif.full_sum
tb_top.vif.full_cout
```

## Useful UVM coding-practice targets

The most common interview-sized blocks are usually:
- sequence_item / transaction
- constraint / randomization
- sequence
- driver
- monitor
- scoreboard / reference model
- interface / clocking block
- analysis_port / analysis_imp
- SVA
- functional coverage

A full UVM environment from scratch is possible, but usually too large for a short hand-coding question.
