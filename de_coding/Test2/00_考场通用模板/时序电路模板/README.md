# 时序电路模板

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `时序电路模板`，RTL 顶层/子模块为 `ExamSeq`。 源文件说明：考场时序电路模板：先锁存两个操作数，再每个时钟处理一位；算完后 DONE 拉高一个时钟周期。 默认示例计算低 N 位的逐位异或。考场需按题目修改标有“修改点”的地方，不能只改设计而忘记修改测试期望。

**RTL 文件：**`ExamSeq.v`。

**TB 文件：**
- `ExamSeq_tb.v`（顶层 `ExamSeq_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
