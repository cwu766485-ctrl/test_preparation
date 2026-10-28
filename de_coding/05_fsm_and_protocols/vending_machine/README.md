# 自动售货机控制器

RTL 文件： `vending_machine.v`<br>
TB 文件： `tb_vending_machine.v`<br>
顶层模块： `vending_machine`

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

**设计说明：**本题练习 `vending machine`，RTL 顶层/子模块为 `vending_machine`。 源文件说明：商品价格为 15 单位的简易售货机。每周期接收一枚 5 单位或 10 单位硬币；DISPENSE 和 CHANGE 只输出一个周期，出货后余额清零。

**RTL 文件：**`vending_machine.v`。

**TB 文件：**
- `tb_vending_machine.v`（顶层 `tb_vending_machine`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
