# T3 · 门级 VCS 仿真

此目录用匹配的标准单元模型和 SDF 对综合网表进行仿真。不要混用不同综合批次生成的文件。脚本会把 Syn_<TOP>.v/.sdf、行为级 testbench、可选向量文件和 SDC 复制到此目录；library.f 必须列出正确的课程模型。

在课程 C shell 中运行：

~~~csh
csh run
~~~

检查 compile_gate.log 和 sim_gate.log，确认 SDF 成功标注，并执行与 T1 相同的功能检查。进入 T4 前确认 inter.vpd 已生成。$sdf_annotate 中的 DUT 实例路径必须与实际 testbench 一致，并同步检查 exam_config.csh。
