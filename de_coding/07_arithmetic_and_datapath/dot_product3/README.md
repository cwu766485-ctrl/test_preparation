# 三项点积

RTL 文件： `dot_product3.v`<br>
TB 文件： `tb_dot_product3.v`<br>
顶层模块： `dot_product3`

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

**设计说明：**本题练习 `dot product3`，RTL 顶层/子模块为 `dot_product3`。 源文件说明：有符号三项点积。START 采样第 0 项，之后两个时钟沿分别采样第 1 项和第 2 项；DONE 输出一个周期的脉冲。

**RTL 文件：**`dot_product3.v`。

**TB 文件：**
- `tb_dot_product3.v`（顶层 `tb_dot_product3`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
