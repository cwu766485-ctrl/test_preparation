// 顶层：M3 全加器 + M4 控制器 + M5 风格的寄存器数据通路。
module SerialAdder (
    input  wire        CLK,
    input  wire        NRST,
    input  wire        START,
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire [4:0]  N,
    output reg  [15:0] SUM,
    output reg         COUT,
    output wire        DONE
);
    wire load, step, last;
    wire sum_bit, carry_bit;
    wire [4:0] index;
    reg [15:0] a_q, b_q;
    reg carry_q;

    SerialAdderController U_CTRL (
        .CLK(CLK), .NRST(NRST), .START(START), .N(N),
        .LOAD(load), .STEP(step), .LAST(last), .INDEX(index), .DONE(DONE)
    );

    FullAdder U_FA (
        .A(a_q[0]), .B(b_q[0]), .CIN(carry_q),
        .S(sum_bit), .COUT(carry_bit)
    );

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            a_q     <= 16'd0;
            b_q     <= 16'd0;
            carry_q <= 1'b0;
            SUM     <= 16'd0;
            COUT    <= 1'b0;
        end else if (load) begin
            a_q     <= A;
            b_q     <= B;
            carry_q <= 1'b0;
            SUM     <= 16'd0;
            COUT    <= 1'b0;
        end else if (step) begin
            SUM[index] <= sum_bit;  // 第 index 位写回原位置，结果对齐低位。
            carry_q    <= carry_bit;
            a_q        <= a_q >> 1;
            b_q        <= b_q >> 1;
            if (last)
                COUT <= carry_bit;
        end
    end
endmodule
