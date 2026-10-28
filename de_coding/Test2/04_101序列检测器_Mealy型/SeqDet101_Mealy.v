// ============================================================
// 第 4 题：Mealy 型状态机，检测串行输入 DIN 中的 101，允许重叠。
// 当最后一位 1 出现在 DIN 上时，DET 在同一个周期即可为 1。
// 第 2 题的 Moore 型版本需要额外的已检测状态，输出在采样后才出现。
// Mealy 输出同时由当前状态和当前输入决定。
// 因此可少用一个状态，且不用等待输入再被登记到结果状态。
// 由于 DET 组合地跟随 DIN，如果 DIN 有毛刺，DET 也可能出现毛刺。
// ============================================================
module SeqDet101_Mealy (
    input  wire CLK,
    input  wire NRST,
    input  wire DIN,
    output wire DET
);
    parameter S0 = 2'b00;   // S0：尚未保留有效前缀。
    parameter S1 = 2'b01;   // S1：末尾已经收到 1。
    parameter S2 = 2'b10;   // S2：末尾已经收到 10。

    reg [1:0] state, next_state;

    // 第一部分：上升沿更新状态寄存器。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            state <= S0;
        else
            state <= next_state;
    end

    // 第二部分：依据当前状态和 DIN 决定下一状态。
    always @(state or DIN) begin
        case (state)
            S0: next_state = DIN ? S1 : S0;
            S1: next_state = DIN ? S1 : S2;
            S2: next_state = DIN ? S1 : S0;   // 在 S2 收到 1 完成 101；这位 1 同时是下一次模式的开头，因此回 S1。
            default: next_state = S0;         // 编码 11 未使用，发生非法状态时回到 S0。
        endcase
    end

    // 第三部分：DET 由当前状态和 DIN 共同决定，属于组合输出。
    assign DET = (state == S2) && DIN;
endmodule
