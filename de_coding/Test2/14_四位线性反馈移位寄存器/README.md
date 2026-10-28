# 14_四位线性反馈移位寄存器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `14_四位线性反馈移位寄存器`，RTL 顶层/子模块为 `LFSR4`。 源文件说明：第14题：4 位线性反馈移位寄存器，用于产生伪随机序列。反馈位 fb=Q[3] 异或 Q[2]；EN=1 时，每拍执行 Q<={Q[2:0],fb}。复位种子取 0001，不能取 0000，因为全零状态会一直锁死；理论周期为 15 个非零状态。

**RTL 文件：**`LFSR4.v`。

**TB 文件：**
- `LFSR4_tb.v`（顶层 `LFSR4_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
