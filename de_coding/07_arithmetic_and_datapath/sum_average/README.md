# 求和与平均值

RTL 文件： `sum_average.v`<br>
TB 文件： `tb_sum_average.v`<br>
顶层模块： `sum_average`

## 考试命令 (Linux / Rocky Linux)

在当前目录运行以下命令，使用 VCS 编译并运行：

```sh
make
```

自检通过时会打印 PASS:。使用以下命令清除编译器和仿真器生成的文件：

```sh
make clean
```

如果考场中的 Synopsys 环境尚未初始化，请先加载实验室提供的环境脚本，再运行 make。

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `sum average`，RTL 顶层/子模块为 `sum_average`。 源文件说明：对 COUNT 个无符号数据流样本求和并计算整数平均值。START 启动模块；之后仅在 VALID=1 的周期接收样本。

**RTL 文件：**`sum_average.v`。

**TB 文件：**
- `tb_sum_average.v`（顶层 `tb_sum_average`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
