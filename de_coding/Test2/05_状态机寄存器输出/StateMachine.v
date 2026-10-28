// ============================================================
// 第 5 题：Module 4 状态机，输出 S 和 COUT 由寄存器驱动，避免组合毛刺。
// 对应 Module 4 的可选进阶题。
// 状态转移规则沿用 Module 4：
// S0 收到 start 转 S1；S1/S2/S3 收到 rst 回 S0；否则依次 S1→S2→S3→S1。
// S 在 S1 或 S3 时为 A、B、CIN 的全加器和位，其他状态为 0。
// COUT 在 S2 或 S3 时为全加器进位，其他状态为 0。
// S 与 COUT 经触发器输出，只能在时钟上升沿后改变，
// 因此减少毛刺；代价是多用两个触发器，而且输出比组合版晚一拍。
// 模块名及端口名沿用 Module 4，原有综合脚本可继续使用。
// ============================================================
module StateMachine (
    input  wire CLK,
    input  wire NRST,     // 低电平有效异步复位。
    input  wire start,
    input  wire rst,      // 同步控制状态机回到 S0 的信号。
    input  wire CIN,
    input  wire A,
    input  wire B,
    output reg  S,        // 组合版此处是 output wire；本版输出由寄存器驱动。
    output reg  COUT
);
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    reg  [1:0] state, next_state;
    wire       S_comb, COUT_comb;          // 原规格中的组合和位与进位，作为输出寄存器的输入。

    // 状态寄存器及两个输出寄存器共用同一 CLK 和 NRST。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= S0;
            S     <= 1'b0;
            COUT  <= 1'b0;
        end else begin
            state <= next_state;
            S     <= S_comb;                // 在本拍上升沿锁存由旧状态计算的组合和位。
            COUT  <= COUT_comb;             // 同理锁存组合进位；因此输出只在上升沿后变化。
        end
    end

    // 下一状态逻辑沿用 Module 4 规则。
    always @(state or start or rst) begin
        case (state)
            S0: next_state = start ? S1 : S0;
            S1: next_state = rst   ? S0 : S2;
            S2: next_state = rst   ? S0 : S3;
            S3: next_state = rst   ? S0 : S1;
            default: next_state = S0;
        endcase
    end

    // 组合输出译码沿用 Module 4 规则。
    assign S_comb    = ((state == S1) || (state == S3)) ? (A ^ B ^ CIN) : 1'b0;
    assign COUT_comb = ((state == S2) || (state == S3)) ? ((A & B) | (CIN & (A ^ B))) : 1'b0;

    // 下面保留原 Module 4 组合输出的写法供对照，此处是注释，不参与电路。
    // output wire S, COUT;
    // assign S    = S_comb;
    // assign COUT = COUT_comb;
endmodule
