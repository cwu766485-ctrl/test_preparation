# Verilog and VCS runs

Every generated RTL directory has one plain `Makefile`. Use `make` to run all
module smoke tests in that directory, or `make test_<module>` for one module.
Use `make clean` to remove that directory's `build/` outputs.

```sh
make
make test_sync_fifo
make clean
```

The complete generated smoke suite can be run in Rocky Linux 8.10 WSL with the
reviewed project task:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\惠普\.codex\skills\rocky-wsl-bridge\scripts\invoke-rocky.ps1 `
  -ProjectRoot E:\Desktop\ic_de_dv\foundation `
  -ConfigPath E:\Desktop\ic_de_dv\foundation\de_coding\tools\rocky-bridge.tasks.json `
  -WslWorkingDirectory /mnt/e/Desktop/ic_de_dv/foundation/de_coding `
  -Task vcs-all
```

The smoke test drives inputs for 24 cycles and reports unknown outputs. The
uninitialized asynchronous dual-port RAM read-data outputs are excluded from
that check. Dedicated functional tests are also available for the exam practice
modules listed in [`EXAM_CODE_PRACTICE.md`](../EXAM_CODE_PRACTICE.md).
