# Digital IC RTL Coding Practice

`de_coding` is organized into seven topic folders, plus `Test2` exam-style
problems and shared VCS helpers. See [`MAP.md`](MAP.md) for the directory map,
module topics, quick search commands, and simulation entry points.

## Sections

| Folder | Topics |
|---|---|
| `01_combinational_logic` | Adders, muxes, encoders, comparators, parity, popcount, shifters |
| `02_sequential_logic` | Registers, counters, sequence detection, edge detection, dividers |
| `03_clock_domain_crossing` | Synchronizers, pulse/handshake CDC, Gray pointers, reset and clock switching |
| `04_memory_and_interfaces` | RAM, FIFOs, and serial/parallel interfaces |
| `05_fsm_and_protocols` | Moore/Mealy FSMs, handshakes, PWM, debounce, vending machine |
| `06_advanced_topics_and_systems` | Arbiter, CRC, LFSR, clock dividers, display scan, LUT, UART |
| `07_arithmetic_and_datapath` | Arithmetic, serial datapaths, matrix/dot-product, multiplier/divider, ALU |

## Run and clean

Most exercise directories provide a plain `Makefile`:

```sh
cd 02_sequential_logic/counters
make
make clean
```

For Linux/WSL setup and the whole-project VCS runs, see [`tools/VCS_USAGE.md`](tools/VCS_USAGE.md).
