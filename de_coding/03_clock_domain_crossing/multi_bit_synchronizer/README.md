# 多比特同步器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `multi bit synchronizer`，RTL 顶层/子模块为 `multi_bit_synchronizer`, `multi_bit_synchronizer`。 源文件说明：用于低频多比特数据传输的 bundled-data 四阶段握手同步器。

**RTL 文件：**`multi_bit_synchronizer.sv`, `multi_bit_synchronizer.v`。

**TB 文件：**
- `tb_multi_bit_synchronizer_smoke.v`（顶层 `tb_multi_bit_synchronizer_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
