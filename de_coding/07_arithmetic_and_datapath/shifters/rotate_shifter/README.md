# 循环移位器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `rotate shifter`，RTL 顶层/子模块为 `rotate_shifter`。 源文件说明：循环移位器通过回绕移出的位来保留全部数据位。缺点：需要额外回绕逻辑，并需特别处理移位量为 0。dir=1 右旋，dir=0 左旋。

**RTL 文件：**`rotate_shifter.v`。

**TB 文件：**
- `tb_rotate_shifter_smoke.v`（顶层 `tb_rotate_shifter_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
