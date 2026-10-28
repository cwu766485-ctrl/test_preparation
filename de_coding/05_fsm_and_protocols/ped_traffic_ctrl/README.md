# Mock5：带行人请求的交通灯控制器

## 题目与接口

顶层模块 ped_traffic_ctrl。状态包含 GREEN、YELLOW、ALL_RED 和 WALK。参数 GREEN_TICKS、YELLOW_TICKS、ALL_RED_TICKS、WALK_TICKS 分别设置各阶段持续的 tick 数。tick 是同步使能：tick=1 时计时并允许状态推进；tick=0 时计时冻结。行人请求 ped_req 在有效采样沿锁存。

输出 car_green、car_yellow、car_red 和 walk 对应当前相位；行人通行 WALK 阶段同时保持车辆红灯。phase 暴露状态编码用于观察和验证。

## RTL 电路说明

RTL 位于 rtl/ped_traffic_ctrl.v。

- phase 寄存器保存 FSM 状态；elapsed 计数当前阶段已经经历的 tick 数。
- 在 GREEN、YELLOW 或 ALL_RED 阶段采到 ped_req 后，pending 置位；WALK 阶段的请求不排队。
- 正常状态顺序为 GREEN → YELLOW → ALL_RED。ALL_RED 时间结束时，如果 pending 或当前周期有新请求，则转到 WALK；否则回到 GREEN。WALK 结束后回到 GREEN。
- tick=0 时 FSM 计时器和相位不推进，但 ped_req 仍可被记录。
- rst_n 为低有效异步复位，复位后车辆绿灯相位有效、计时清零、无待处理行人请求。

## TB 与验证命令

tb/tb_ped_traffic_ctrl.sv 用独立的软件状态/计时参考模型逐周期检查相位和灯输出；覆盖无请求循环、tick 停顿时锁存请求、随机请求与停顿、车辆灯互斥安全条件及运行中复位。

在本目录运行：

    make test
    make clean

test 用 VCS 运行行为级 TB，生成物放在 build/。tb/tb_ped_traffic_ctrl_gate.sv 只用于已经有匹配网表、SDF 和工艺库模型的门级仿真。
## 本次验证结果

2026-10-28 在 Rocky Linux 8.10 WSL 使用 VCS V-2023.12-SP1 运行 make test：PASS，388 次参考模型输出检查。随后 make clean 已清理 build/.
