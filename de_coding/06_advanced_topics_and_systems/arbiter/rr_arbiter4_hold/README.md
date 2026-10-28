# Mock6：带反压保持的 4 路轮询仲裁器

## 题目与接口

顶层模块 rr_arbiter4_hold。req[3:0] 表示四个请求，grant[3:0] 是 one-hot 授权，grant_valid 表示当前有授权，ready 表示接收端可以接受本次传输。复位后优先级从请求 0 开始。

## RTL 电路说明

RTL 位于 rtl/rr_arbiter4_hold.v。

- pointer 保存下一次轮询的起始请求编号。
- 空闲授权时，从 pointer 开始按 0、1、2、3 循环检查 req，选中第一个有效请求；没有请求时 grant=0。
- grant_valid=1 且 ready=1 表示传输完成。此时 pointer 更新为获胜请求的下一路，实现轮询公平性。
- grant_valid=1 且 ready=0 时，holding/held_grant 锁住当前授权。即使请求方随后撤销 req，grant 仍保持不变，直到 ready 接受该传输。
- rst_n 为低有效异步复位，清除优先级指针和保持状态。

## TB 与验证命令

tb/tb_rr_arbiter4_hold.sv 用独立参考指针计算期望授权，检查 one-hot、连续全请求时的 0→1→2→3 轮转、反压期间保持授权、撤销请求后的保持、随机请求/ready 和异步复位。

在本目录运行：

    make test
    make clean

test 用 VCS 运行 RTL TB，生成物位于 build/。tb/tb_rr_arbiter4_hold_gate.sv 需要综合网表、匹配 SDF 和工艺库模型，仅用于门级仿真。
## 本次验证结果

2026-10-28 在 Rocky Linux 8.10 WSL 使用 VCS V-2023.12-SP1 运行 make test：PASS，268 次仲裁输出/状态检查。随后 make clean 已清理 build/.
