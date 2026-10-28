# Modular Serial Adder

RTL: `full_adder.v serial_adder.v serial_adder_controller.v`  
Testbench: `tb_serial_adder.v`  
Top module: `modular_serial_adder`

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
