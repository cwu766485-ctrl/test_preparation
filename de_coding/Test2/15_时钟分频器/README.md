# 15_时钟分频器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `15_时钟分频器`，RTL 顶层/子模块为 `ClkDiv`。 源文件说明：第15题：输出 50% 占空比的 4 分频和 5 分频。4 分频直接取二位计数器最高位，输出每两拍翻转。5 分频计数 0 到 4；p 在输入时钟上升沿更新，n 在下降沿复制 p；p 或 n 合成高电平长度 2.5 个输入周期。

**RTL 文件：**`ClkDiv.v`。

**TB 文件：**
- `ClkDiv_tb.v`（顶层 `ClkDiv_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
