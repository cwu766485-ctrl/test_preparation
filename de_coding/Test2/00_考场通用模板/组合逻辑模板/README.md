# 组合逻辑模板

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `组合逻辑模板`，RTL 顶层/子模块为 `ExamComb`。 源文件说明：考场组合逻辑模板：输出只由当前输入决定，没有时钟和内部状态。 默认示例为 8 位异或；结果等于零时 FLAG 为 1。

**RTL 文件：**`ExamComb.v`。

**TB 文件：**
- `ExamComb_tb.v`（顶层 `ExamComb_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
