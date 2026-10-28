# Shared tools

- `VCS_USAGE.md`: command usage and Rocky Linux VCS setup.
- `EXAM_REPORT_GUIDE.md`: NM6008 report outline, Module 3 synthesis/gate flow,
  and Module 6 layout prerequisites.
- `run_vcs_all.sh`, `run_sv_vcs.sh`, `run_test2_vcs.sh`,
  `run_missing_code_vcs.sh`, `run_secretcode_vcs.sh`: self-checking regressions;
  scripts that create temporary workspaces clean them automatically.
- `prepare_exam_readmes.py`: regenerate the topic README quick-reference blocks.
- `add_vcd_dumps.py`: add portable VCD capture to testbenches lacking VCD/VPD
  dump calls.
- `rocky-bridge.tasks.json`: reviewed task definitions used by the Windows to
  Rocky WSL bridge.

Use a test's `make clean` after capturing report artifacts. Do not commit VCS
build outputs or restricted course library files.
