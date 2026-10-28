# 共用工具

- VCS_USAGE.md：VCS 命令及 Rocky Linux 环境说明。
- EXAM_REPORT_GUIDE.md：NM6008 报告大纲、Module 3 综合/门级流程和 Module 6 布局前置条件。
- run_vcs_all.sh、run_sv_vcs.sh、run_test2_vcs.sh、run_missing_code_vcs.sh、run_secretcode_vcs.sh：自检回归脚本；会创建临时工作目录的脚本会自动清理。
- prepare_exam_readmes.py：重新生成各练习目录的 README 速查区块。
- add_vcd_dumps.py：为尚未记录波形的 testbench 增加可移植的 VCD 输出。
- rocky-bridge.tasks.json：Windows 到 Rocky WSL 桥接工具使用的已审查任务定义。

保存报告所需材料后，在对应练习目录运行 make clean。不要提交 VCS 编译产物或受限制的课程工艺库文件。
