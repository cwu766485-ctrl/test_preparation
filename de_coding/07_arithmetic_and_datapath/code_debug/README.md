# Code Debug

RTL: `buggy_shift_reg.v code_debug_shift_reg.v`  
Testbench: `tb_code_debug.v`  
Top module: `code_debug`

## Exam commands (Linux / Rocky Linux)

From this directory, compile and run with VCS:

```sh
make
```

A successful self-check prints `PASS:`. Remove compiler and simulator outputs with:

```sh
make clean
```

If the Synopsys environment is not initialized in the exam lab, source the lab-provided setup script before running `make`.
