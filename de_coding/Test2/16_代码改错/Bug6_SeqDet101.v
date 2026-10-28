// ============================================================
// 改错题 6：Moore 型可重叠检测器，依次收到 101 后 DET 应在相应时钟后置 1 一拍。组合状态转移依赖 state 和 DIN，但敏感列表故意只写 state：DIN 单独变化时，行为仿真不会重算 next_state；综合出的组合逻辑可能与仿真表现不同。
// ============================================================
module SeqDet101 (
    input  wire CLK,
    input  wire NRST,
    input  wire DIN,
    output wire DET
);
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    reg [1:0] state, next_state;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            state <= S0;
        else
            state <= next_state;
    end

    always @(state) begin // 故意保留：漏掉 DIN，行为仿真可能使用过期的 next_state。
        case (state)
            S0: next_state = DIN ? S1 : S0;
            S1: next_state = DIN ? S1 : S2;
            S2: next_state = DIN ? S3 : S0;
            S3: next_state = DIN ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    assign DET = (state == S3);
endmodule
