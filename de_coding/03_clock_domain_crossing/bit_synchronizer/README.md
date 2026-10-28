# 单比特同步器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `bit synchronizer`，RTL 顶层/子模块为 `bit_sync2`, `bit_sync2`。 源文件说明：用于慢时钟域的持续单比特电平同步；短脉冲应改用事件 CDC 电路传输。

**RTL 文件：**`bit_synchronizer.sv`, `bit_synchronizer.v`。

**TB 文件：**
- `tb_bit_sync2_smoke.v`（顶层 `tb_bit_sync2_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
