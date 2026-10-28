// ============================================================
// 改错题 5：组合 4 选 1，SEL=00/01/10/11 应选择 D0/D1/D2/D3。这里故意漏掉 SEL=11 的赋值，导致 Y 保持旧值，并综合出锁存器；用 Mux4_tb.v 验证。
// ============================================================
module Mux4 (
    input  wire [3:0] D0,
    input  wire [3:0] D1,
    input  wire [3:0] D2,
    input  wire [3:0] D3,
    input  wire [1:0] SEL,
    output reg  [3:0] Y
);
    always @(*) begin
        if (SEL == 2'b00)
            Y = D0;
        else if (SEL == 2'b01)
            Y = D1;
        else if (SEL == 2'b10)
            Y = D2;
    end
endmodule
