# 逻辑移位器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `logical shifter`，RTL 顶层/子模块为 `logical_shifter`。 源文件说明：逻辑左右移位器适合无符号数据的简单组合移位。缺点：右移始终补 0，不能保留符号。dir=1 右移，dir=0 左移。

**RTL 文件：**`logical_shifter.v`。

**TB 文件：**
- `tb_logical_shifter_smoke.v`（顶层 `tb_logical_shifter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
