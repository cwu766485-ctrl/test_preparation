# RTL 源码说明

<!-- BEGIN generated exam quick reference -->
## RTL、TB 与考试命令

**设计说明：**NM6008 secret-code 发生器：四个独立 mod-8 数字块或单个 12 位计数器遍历候选码，逻辑块比较并控制 relay。

**RTL 文件：**`secret_code_four.v`, `secret_code_m.v`, `secret_code_single.v`。

**TB 文件：**
- 本目录没有 testbench；在父目录工程或相邻 TB 文件夹运行对应验证。

**VCS：**

```sh
make -C .. test
make -C .. clean
```

仿真由父目录 Makefile 统一编译本目录文件。

综合、门级仿真、波形和报告写作步骤见[考试报告流程](../../../../tools/EXAM_REPORT_GUIDE.md)。
<!-- END generated exam quick reference -->
