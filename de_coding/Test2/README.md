# Test2 题目目录

编号目录中有 29 组考试风格的 RTL/TB 练习。进入具体题目文件夹后，先看其中的 README，了解设计、TB 顶层和 VCS 命令；详细讲解与源文件放在同一题目录中。

一般题目运行方式：

~~~sh
cd de_coding/Test2/<题目文件夹>
make test
make clean
~~~

第 16 题故意包含错误实现；make test 用于确认 TB 能检测出这些错误。完整题集可从 de_coding/ 运行 bash tools/run_test2_vcs.sh。第 17 题“可变位宽串行加法器”与学长报告中的串行加法器题型最接近，并附有详细考试流程说明。

Design Vision 四阶段流程和 Module 6 Innovus 报告步骤见[考试报告流程](../tools/EXAM_REPORT_GUIDE.md)。
