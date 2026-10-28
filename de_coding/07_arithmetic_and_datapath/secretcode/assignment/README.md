# NM6008 作业题：Secret Code 数字发生器

本目录实现预设四位秘密码的搜索电路。上级目录的 Behavioral/ 和 rtl/ 是另一道键盘密码锁练习；题目要求数字发生器时使用本 assignment 版本。

## 1. RTL 与 TB 设计

- rtl/secret_code_m.v：一个独立的 3 位 mod-8 计数器，没有 secret_code 输入端口。
- rtl/secret_code_four.v：把四个 M 模块级联为八进制里程表。候选码为 {v1,v2,v3,v4}；每个搜索周期 v4 加一，进位时带动更高位。顶层锁存并比较秘密码，匹配后停止计数并打开继电器。
- rtl/secret_code_single.v：用于对比的单个 12 位计数器替代实现。
- tb/tb_secret_code.sv：逐周期比较两种实现，并检查重新启动、异步复位、继电器保持、7→0 回绕，以及 0000、0123、1145、7777（八进制）等码值。1145 表示 12'o1145，不是十进制 1145。

activate 有效时锁存秘密码。每个数字是 0..7 的 3 位值；按作业说明，学生 ID 中的 8 和 9 分别替换为 0 和 1。匹配后，继电器保持打开，直到复位或重新激活。

## 2. 考试运行命令

在课程 Linux/WSL 终端中，如尚未配置 VCS，请先加载实验室提供的 VCS 环境脚本，然后运行：

~~~sh
cd de_coding/07_arithmetic_and_datapath/secretcode/assignment
make test
make clean
~~~

make test 会打印 PASS，波形位于 build/secretcode_search.vcd。交互式运行 DVE 使用 make gui；在波形窗口加入 candidate_four、busy_four 和 relay_four。

## 3. 综合与报告

Module 3 Design Vision 流程见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。使用相同 GF22 配置和约束，分别综合 secret_code_four 和 secret_code_single；保存各自的 report.rpt、时序报告、门级网表、SDF 和原理图截图，并在报告中比较面积和关键路径延时。PDK 由课程提供；本练习目录不包含标准单元库和许可证配置。
