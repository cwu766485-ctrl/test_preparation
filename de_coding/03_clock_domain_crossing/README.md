# CDC 练习：按传输语义选结构

| 场景 | 示例 | 条件与限制 |
|---|---|---|
| 持续的单 bit 电平 | `bit_synchronizer/bit_synchronizer.sv` | 电平需保持足够久；不能计数事件 |
| 一次低频事件 | `pulse_sync/pulse_sync.sv` | 开环 toggle；两次翻转之间须被目标域观察到 |
| 每次事件必须送达 | `pulse_sync/pulse_handshake.sv` | 只有 `src_ready=1` 的脉冲被接受；背压期间源端要保持/排队 |
| 事件批量计数 | `pulse_sync/event_counter_cdc.sv` | 模计数；两次观察间事件数不能达到 `2**COUNT_W` |
| 偶发多 bit 数据 | `multi_bit_synchronizer/multi_bit_synchronizer.sv` | bundled-data 四相握手；源数据锁存并保持至完成 |
| 连续数据流 | `../04_memory_and_interfaces/async_fifo/async_fifo.sv` | 双口存储器与 Gray 读写指针；需要独立验证满/空逻辑 |
| FIFO 指针 | `gray_pointer/gray_pointer.sv` | 源域寄存 Gray，目标域两级同步，约束总线位间 skew |
| 中断事件 | `interrupt_cdc/interrupt_cdc.sv` | 目标域粘滞 pending，软件 clear；事件可合并 |
| 复位 | `reset_synchronizer/` | 异步拉低，每域独立同步释放 |
| 时钟切换 | `glitch_free_clock_switch/` | 教学 RTL；实际芯片优先专用无毛刺时钟 mux cell |

## 必要的边界条件

- 所有跨域请求/事件示例假设两个时钟域处于同一次协调复位。若一个域单独复位，必须先停止新传输，并定义未完成传输的丢弃、重试或排空规则。
- `multi_bit_synchronizer` 是完整的四相握手实现。接收侧没有 `dst_ready`，必须在 `dst_valid` 当拍消费数据。
- Gray 编码必须在**源时钟域寄存**后跨域。不能先跨域 binary 总线，再在目标域编码；不同 bit 的采样可能来自不同源时刻。
- FIFO 指针允许目标域跳过中间值，不要求目标频率大于源频率；关键是源端一次只加 1，且物理 skew 约束防止不同更新在途中重叠。
- `ASYNC_REG` / `SHREG_EXTRACT` 是工具提示，具体约束、复位检查、CDC/RDC 报告和 MTBF 计算仍需按目标工艺与 EDA 工具完成。

## 四类多 bit 跨域的区别

1. **偶发配置字/状态快照**：四相握手。`src_valid && src_ready` 时源端锁存一个字，目标域收到请求后取样，并用 ack 告知源端。总线不能逐 bit 独立打拍。
2. **连续数据流**：异步 FIFO。双口存储器存数据，Gray 读写指针跨域，分别在本地域判断空/满。该目录中的 `gray_ptr_sync` 只负责指针跨域。
3. **计数器/指针**：源域寄存 Gray 编码，再逐 bit 两拍同步；目标域可以跳过中间值。普通任意多 bit 数据不适用。
4. **需要目标域接收背压的命令**：当前 `multi_bit_synchronizer` 没有 `dst_ready`；可在目标域增加寄存器/小 FIFO，或者扩展 ack 使其在消费后才返回。

## 脉冲与中断

- `pulse_sync` 的 `pulse_i` 必须被源时钟采到。若输入是异步窄毛刺，先在源域捕获/拉宽；toggle 只能解决跨到目标域时的窄脉冲问题。
- 开环 toggle 两次翻转可能相互抵消。四相握手提供 `src_ready`，源端必须在未 ready 时保存事件。计数器可报告批量事件，但输出是“数量”，不是逐个脉冲，且计数模数限制必须满足。
- `interrupt_cdc` 将已接受事件变成目标域粘滞中断；多个事件可合并。若必须分别处理每次中断，使用计数器或 FIFO。
- 若两域复位不是同时有效，toggle/Gray/握手状态可能被解释成假事件。应在复位期间阻止新事件，等两域重新就绪后再启动协议；单侧复位还需定义未完成事件如何处理。
