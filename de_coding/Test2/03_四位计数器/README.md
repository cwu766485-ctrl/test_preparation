# 03_四位计数器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `03_四位计数器`，RTL 顶层/子模块为 `Counter4`。 源文件说明：第 3 题：4 位向上计数器，数值按 0、1、…、15、0 循环。 NRST：低电平有效异步复位，发生时立即把 Q 清零。 CLR：高电平有效同步清零，只在下一时钟上升沿生效。 EN：计数使能；EN=0 时保持 Q 不变。 Q：当前 4 位计数值，15 再加 1 自动回到 0。 TC：终值指示；仅在 EN=1 且 Q=15 时为 1，可用于级联计数器…

**RTL 文件：**`Counter4.v`。

**TB 文件：**
- `Counter4_tb.v`（顶层 `Counter4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
