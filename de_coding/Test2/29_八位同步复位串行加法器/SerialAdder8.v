// 顶层：一个 M3 全加器 + M4 控制器 + M5 风格移位寄存器。
module SerialAdder8 (
    input wire CLK,
    input wire NRST,
    input wire START,
    input wire [7:0] A,
    input wire [7:0] B,
    input wire [3:0] N,
    output reg [7:0] SUM,
    output reg COUT,
    output wire DONE
);
    wire load, step, last;
    wire sum_bit, carry_bit;
    wire [3:0] index;
    reg [7:0] a_q, b_q;
    reg carry_q;

    SerialAdder8Controller U_CTRL (
        .CLK(CLK), .NRST(NRST), .START(START), .N(N),
        .LOAD(load), .STEP(step), .LAST(last), .INDEX(index), .DONE(DONE)
    );

    FullAdder U_FA (
        .A(a_q[0]), .B(b_q[0]), .CIN(carry_q),
        .S(sum_bit), .COUT(carry_bit)
    );

    // 与控制器一样改成同步复位；两处必须一起改。
    always @(posedge CLK) begin
        if (!NRST) begin
            a_q     <= 8'd0;
            b_q     <= 8'd0;
            carry_q <= 1'b0;
            SUM     <= 8'd0;
            COUT    <= 1'b0;
        end else if (load) begin
            a_q     <= A;
            b_q     <= B;
            carry_q <= 1'b0;
            SUM     <= 8'd0;
            COUT    <= 1'b0;
        end else if (step) begin
            SUM[index] <= sum_bit;
            carry_q    <= carry_bit;
            a_q        <= a_q >> 1;
            b_q        <= b_q >> 1;
            if (last)
                COUT <= carry_bit;
        end
    end
endmodule
