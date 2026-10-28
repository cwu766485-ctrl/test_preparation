# T1 · Behavioral VCS

This folder is the behavioral simulation stage of the four-stage exam template.
Copy the question's synthesizable RTL, testbench, and any `InputVector.txt` into
this folder. Edit `../exam_config.csh` with the exact RTL filenames, top module,
testbench module, and DUT instance.

From this folder in the course C shell:

```csh
csh run
```

The script loads the VCS setup and produces `compile_beh.log`, `sim_beh.log`,
and any testbench check/waveform files. Review the self-check results and open
`./simv -gui` for the waveform before moving to T2. This template is not a
substitute for checking that the TB compares outputs against expected values.
