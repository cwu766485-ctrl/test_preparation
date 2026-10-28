# T2 · Design Vision 综合

只把可综合 RTL 放入 sources/。Synthesis/run 脚本会复制上级 exam_config.csh 中列出的文件，并生成 scripts/ReadVerilogFiles.tcl。运行前，将顶层 Tcl 文件改名为 scripts/<TOP>.tcl；让 scripts/run_topdown.tcl 调用它；核对顶层名称、MyDefaults.con 约束，并保留课程提供的 GF22 配置和工艺库文件。

在课程 C shell 中运行：

~~~csh
csh run
~~~

检查 logs/run_exam_syn.log、logs/report.rpt，以及可能生成的 netlist/Syn_<TOP>.v、.sdf 和 .sdc。确认映射到工艺库单元，并检查面积、时序/裕量和功耗报告；在 Design Vision 的 Schematic View 中打开映射后的顶层并保存截图。如果批处理 Tcl 与机房软件版本不兼容，可按[考试报告流程](../../../tools/EXAM_REPORT_GUIDE.md)从 Design Vision 图形界面执行 scripts/run_topdown.tcl。
