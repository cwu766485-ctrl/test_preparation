# T4 · SAIF 功耗分析

此阶段把 T3 的 inter.vpd 开关活动转换为 VCD/SAIF，在 dc_shell-xg-t 中读取对应的综合网表，把 SAIF 活动映射到 <TB_MODULE>/<DUT_INSTANCE>，并生成 rpt_saif.txt 以及单元级/层次级功耗报告。需要匹配的课程 PDK、VCS 和 DC 工艺库配置。

在课程 C shell 中运行：

~~~csh
csh run
~~~

从 rpt_power.txt 记录 Total Power 及单位，并在 rpt_saif.txt 中检查未匹配的活动信号。如果没有 inter.vpd，先启用 VPD 记录并重新运行 T3。图形界面或手动操作方法见[考试报告流程](../../../../tools/EXAM_REPORT_GUIDE.md)。
