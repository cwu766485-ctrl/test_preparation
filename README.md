# NM6008 Secret Code — Mock Exam Preparation

This is an independent practice solution, not a tested GF22 sign-off.

## Contents
- `rtl/digit_counter.v`: independent 3-bit mod-8 M element.
- `rtl/secret_code_four.v`: four M blocks plus separately located match logic.
- `rtl/secret_code_single.v`: one 12-bit counter alternative.
- `tb/tb_secret_code.sv`: self-checking RTL equivalence and corner-case regression.
- `tb/tb_secret_code_gate.sv`: one-top gate simulation with optional SDF/VPD.
- `synth/scripts/`: Design Compiler scripts for the four-M variant.
- `docs/NM6008_SecretCode_Lab3_4_5_Guide.txt`: detailed laboratory instructions.

## Design contract
`secret_code[11:9]` = v1, `[8:6]` = v2, `[5:3]` = v3, `[2:0]` = v4.
Each digit takes values 0..7. `activate` synchronously (re)starts a search
from 0000. The candidate is enumerated in base 8; upon match the relay
asserts and stays open until a new start or reset. `busy` signals search.
The candidate-generator M blocks have no secret-code input.
The external logic compares generated digits with the supplied preset code.

Example: digits 1,1,4,5 are written as `12'o1145` (not `12'd1145`).
For an ID decimal digit 8 substitute 0; for 9 substitute 1.

## Quick run (from repo root, after VCS environment is sourced)
```sh
vcs -debug +v2k -sverilog -top tb_secret_code -o simv \
    tb/tb_secret_code.sv rtl/digit_counter.v \
    rtl/secret_code_four.v rtl/secret_code_single.v
./simv
./simv -gui
```
Do not publish PDK libraries, commercial standard-cell models, license
files, or confidential course materials in this public repository.
