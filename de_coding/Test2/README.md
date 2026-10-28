# Test2 question folders

The numbered folders contain the 29 exam-style RTL/TB examples. Open the local
`README.md` first for the design summary, TB top, and VCS command; detailed
explanations from the original practice notes remain beside the source files.

For a normal question folder:

```sh
cd de_coding/Test2/<question-folder>
make test
make clean
```

Question 16 contains intentional bugs; `make test` checks that its benches detect
them. For the full set, use `bash tools/run_test2_vcs.sh` from `de_coding/`.
`17_可变位宽串行加法器/` is the closest match to the attached serial-adder
report and has a detailed exam walkthrough.

The four-stage Design Vision and Module 6 Innovus reporting flow is documented
in [`../tools/EXAM_REPORT_GUIDE.md`](../tools/EXAM_REPORT_GUIDE.md).
