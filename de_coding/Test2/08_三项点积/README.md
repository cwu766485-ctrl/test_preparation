# 08_三项点积

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `08_三项点积`，RTL 顶层/子模块为 `DotProduct3`。 源文件说明：第 8 题：三项点积，由 Module 5 的两项运算扩展而来。 OUT=A2×B2+A1×B1+A0×B0；A、B 是有符号 8 位数。 三组操作数连续三拍复用同一组 A/B 输入总线。 空闲时 START 与 A2/B2 同拍到来，启动第一项计算；随后 电路持续运行，每三拍形成下一组结果，直至 NRST 复位…

**RTL 文件：**`DotProduct3.v`。

**TB 文件：**
- `DotProduct3_tb.v`（顶层 `DotProduct3_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
