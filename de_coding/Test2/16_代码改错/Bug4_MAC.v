// ============================================================
// 改错题 4：有符号 8 位 A、B 的乘累加器；EN=1 时 ACC 在上升沿加上 A×B。NRST 异步清零，CLR 同步清零，ACC 是有符号 20 位。这里故意保留两处错误：B 未声明为 signed，且 p 扩展到 20 位时高位补零而非符号扩展。尤其用 A=-2、B=3 检查负数结果。
// ============================================================
module MAC (
    input  wire               CLK,
    input  wire               NRST,
    input  wire               CLR,
    input  wire               EN,
    input  wire signed [7:0]  A,
    input  wire        [7:0]  B,
    output reg  signed [19:0] ACC
);
    wire signed [15:0] p     = $signed(A) * B;
    wire signed [19:0] p_ext = {4'b0000, p}; // 故意保留：负数 p 的高位也补零，会变成大的正数。

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            ACC <= 20'sd0;
        else if (CLR)
            ACC <= 20'sd0;
        else if (EN)
            ACC <= ACC + p_ext;
    end
endmodule
