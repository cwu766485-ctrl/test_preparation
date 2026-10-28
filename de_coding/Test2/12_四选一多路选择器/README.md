# 12_四选一多路选择器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `12_四选一多路选择器`，RTL 顶层/子模块为 `Mux4`。 源文件说明：第12题：4 路、每路 4 位的组合多路选择器。SEL=00/01/10/11 分别选择 D0/D1/D2/D3。当前生效的是完整 case 写法；下方还有等价写法与一个专门展示锁存器问题的注释示例。

**RTL 文件：**`Mux4.v`。

**TB 文件：**
- `Mux4_tb.v`（顶层 `Mux4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
