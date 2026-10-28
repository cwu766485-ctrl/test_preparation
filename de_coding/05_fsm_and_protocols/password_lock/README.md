# 密码锁状态机

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**本题练习 `password lock`，RTL 顶层/子模块为 `password_lock`。 源文件说明：依次输入 1、3、5、7 后解锁；错误输入累计三次后报警锁存。

**RTL 文件：**`password_lock.v`。

**TB 文件：**
- `tb_password_lock_smoke.v`（顶层 `tb_password_lock_smoke`）：驱动输入并在仿真中检查 DUT 输出/时序。

**VCS：**

```sh
make test
make clean
```

`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
