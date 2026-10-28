# 101 Moore 序列检测器

RTL 文件： `seq_det_101_moore.v`<br>
TB 文件： `tb_seq_det_101_moore.v`<br>
顶层模块： `seq_det_101_moore`

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

**设计说明：**本题练习 `sequence 101 moore`，RTL 顶层/子模块为 `seq_det_101_moore`。 源文件说明：Moore 状态机检测串行模式 101，并支持重叠匹配。

**RTL 文件：**`seq_det_101_moore.v`。

**TB 文件：**
- `tb_seq_det_101_moore.v`（顶层 `tb_seq_det_101_moore`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
