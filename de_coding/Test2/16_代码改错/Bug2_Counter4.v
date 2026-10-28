// ============================================================
// 改错题 2：规格要求 NRST 低电平有效且异步清零；CLR 同步清零，EN 允许计数，TC=EN 且 Q=15。这里故意保留复位敏感表的错误；检查不等时钟沿是否能立即清零。
// ============================================================
module Counter4 (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       CLR,
    input  wire       EN,
    output reg  [3:0] Q,
    output wire       TC
);
    always @(posedge CLK) begin
        if (!NRST)
            Q <= 4'd0;
        else if (CLR)
            Q <= 4'd0;
        else if (EN)
            Q <= Q + 4'd1;
    end

    assign TC = EN & (Q == 4'd15);
endmodule
