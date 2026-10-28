# Secret-code examples: choose the assignment version

There are two different designs in this parent folder:

- [`assignment/`](assignment/): **use this for the NM6008 number-generator
  assignment** shown in the problem sheet. It contains four independent modulo-8
  generators, an external four-digit comparison/relay logic block, and a
  single-12-bit-counter alternative.
- `Behavioral/` and `rtl/`: an older keypad password-lock exercise with
  key-valid/key-data inputs and a failed-attempt alarm. It is not the assignment
  number generator and does not satisfy that problem's interface.
- `Synthesis/` and `Library/`: course-specific legacy synthesis assets. Library
  files are process-kit data, not portable RTL; do not copy them into GitHub.

For the exam problem, open [`assignment/README.md`](assignment/README.md), run
its VCS test, then use [`../../tools/EXAM_REPORT_GUIDE.md`](../../tools/EXAM_REPORT_GUIDE.md)
for the Module 3 synthesis and report steps. Only run the legacy flows when the
question specifically asks for the keypad-lock behavior.
