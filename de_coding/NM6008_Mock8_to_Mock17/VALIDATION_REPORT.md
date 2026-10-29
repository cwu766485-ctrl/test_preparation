# Validation status

All 10 mocks have been checked for file existence, top-module/TB name agreement,
self-check assertions, waveform/SDF instrumentation and simple syntactic balance.

- Mock 8: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 9: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 10: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 11: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 12: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 13: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 14: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 15: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 16: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.
- Mock 17: RTL/TB module names, generated files, conditionals, and approximate delimiters checked.

**Not performed:** Compilation in Icarus/VCS, simulation, GF22 Design Compiler
synthesis, SDF back-annotation, SAIF-based Power Compiler analysis.
The build container lacks Verilog simulator executables. Static checks are NOT
functional signoff. Run `RUN_ALL_RTL.sh` in a system with iverilog or the per-mock
VCS commands on the lab workstation. Timed SDF checks may need real delay-aware
sampling modifications rather than arbitrary suppression of errors.
