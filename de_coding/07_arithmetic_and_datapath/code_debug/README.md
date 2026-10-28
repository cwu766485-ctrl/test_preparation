# 代码改错练习

RTL 文件： `buggy_shift_reg.v code_debug_shift_reg.v`<br>
TB 文件： `tb_code_debug.v`<br>
顶层模块： `code_debug`

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

**设计说明：**本题练习 `code debug`，RTL 顶层/子模块为 `buggy_shift_reg`, `code_debug_shift_reg`。 源文件说明：此版本故意保留错误供改错练习：阻塞赋值会让新写入的位在同一过程内传播到整个寄存器。

**RTL 文件：**`buggy_shift_reg.v`, `code_debug_shift_reg.v`。

**TB 文件：**
- `tb_code_debug.v`（顶层 `tb_code_debug`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
