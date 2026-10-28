# 25_交通灯控制器

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `25_交通灯控制器`，RTL 顶层/子模块为 `TrafficLight`。 源文件说明：第25题：主路与支路交通灯控制器。CAR=1 表示支路有车等待，是电平信号。 MAIN、SIDE 各用 {红,黄,绿} 三个位编码；每条路同一时刻只能亮一盏灯。 四状态 Moore 状态机：MG 主绿支红至少 T_MG 拍，有车才转 MY；MY 主黄支红 T_Y 拍； SG 主红支绿 T_SG 拍；SY 主红支黄 T_Y 拍，之后回 MG。两路绝不同时非红…

**RTL 文件：**`TrafficLight.v`。

**TB 文件：**
- `TrafficLight_tb.v`（顶层 `TrafficLight_tb`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
