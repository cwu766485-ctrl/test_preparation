# Verilog 与 VCS 运行说明

每个生成 RTL 的练习目录都提供一个普通 Makefile。在目录中运行 make，可执行该目录的模块冒烟测试；运行 make test_<module> 可单独测试某个模块。make clean 会删除该目录生成的 build/ 文件。

~~~sh
make
make test_sync_fifo
make clean
~~~

完整的生成模块冒烟测试套件可在 Rocky Linux 8.10 WSL 中通过已审查的项目任务运行：

~~~powershell
powershell -ExecutionPolicy Bypass -File C:\Users\惠普\.codex\skills\rocky-wsl-bridge\scripts\invoke-rocky.ps1 -ProjectRoot E:\Desktop\ic_de_dv\foundation -ConfigPath E:\Desktop\ic_de_dv\foundation\de_coding\tools\rocky-bridge.tasks.json -WslWorkingDirectory /mnt/e/Desktop/ic_de_dv/foundation/de_coding -Task vcs-all
~~~

冒烟测试驱动 24 个周期的输入并报告未知输出。异步双端口 RAM 未初始化的读数据输出不纳入此项检查。考试练习模块另有专项功能测试，清单见 [EXAM_CODE_PRACTICE.md](../EXAM_CODE_PRACTICE.md)。
