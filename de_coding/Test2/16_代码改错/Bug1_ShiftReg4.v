// ============================================================
// 改错题 1：规格要求 EN=1 时每个上升沿移入 SIN，NRST 是低电平有效异步复位。这里故意保留阻塞赋值造成的移位错误：从低位往高位依次赋值时，同一拍的新值会连锁传递。请对照 ShiftReg4_tb.v 的参考模型观察。
// ============================================================
module ShiftReg4 (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       EN,
    input  wire       SIN,
    output reg  [3:0] Q,
    output wire       SOUT
);
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            Q = 4'b0000;
        else if (EN) begin
            Q[0] = SIN;
            Q[1] = Q[0];
            Q[2] = Q[1];
            Q[3] = Q[2];
        end
    end

    assign SOUT = Q[3];
endmodule
