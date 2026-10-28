`timescale 1ns/1ns

module seq_circuit (
    input  wire A,
    input  wire clk,
    input  wire rst_n,
    output wire Y
);

    reg Q1;
    reg Q0;

    wire D1;
    wire D0;

    // 次态组合逻辑
    assign D1 = A ^ Q1 ^ Q0;
    assign D0 = ~Q0;

    // 输出组合逻辑
    assign Y = Q1 & Q0;

    // 两个 D 触发器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q1 <= 1'b0;
            Q0 <= 1'b0;
        end
        else begin
            Q1 <= D1;
            Q0 <= D0;
        end
    end

endmodule
