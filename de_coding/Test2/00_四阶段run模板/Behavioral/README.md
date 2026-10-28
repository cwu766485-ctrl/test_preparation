# T1 · 行为级 VCS 仿真

此目录用于四阶段考试模板中的行为仿真。把题目要求的可综合 RTL、testbench 和需要的 InputVector.txt 复制到这里。修改上级目录 exam_config.csh，填写准确的 RTL 文件名、顶层模块名、testbench 模块名和 DUT 实例名。

在课程 C shell 中运行：

~~~csh
csh run
~~~

脚本会加载 VCS 环境，并生成 compile_beh.log、sim_beh.log，以及 testbench 检查结果和波形文件。进入 T2 前检查自检结果；可运行 ./simv -gui 查看波形。此模板不能代替 testbench 对照期望值进行检查。
