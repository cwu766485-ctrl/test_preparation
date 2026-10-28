# Secret Code 示例：请选择正确的题目版本

此目录中有两种不同设计：

- [assignment/](assignment/README.md)：NM6008 题面中的 Secret Code 数字发生器。包含四个独立的 mod-8 数字发生器、外部四位比较/继电器逻辑，以及单个 12 位计数器的替代实现。
- Behavioral/ 和 rtl/：较早的键盘密码锁练习，输入为 key_valid/key_data，并带有错误尝试报警。它不是题面要求的数字发生器，接口也不相同。
- Synthesis/ 和 Library/：课程专用的旧综合资源。Library 中是工艺库数据，不是可移植 RTL，不要复制到其他项目。

准备 Secret Code 题时，打开 assignment/README.md 并运行其中的 VCS 测试；Module 3 综合与报告步骤见[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)。只有题目明确要求键盘密码锁行为时，才使用旧练习流程。
