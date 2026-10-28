// ============================================================
// 第 9 题：乘累加器 MAC，逐拍计算多个乘积的总和。
// 每个 EN=1 的上升沿执行 ACC←ACC+A×B；A、B 为有符号 8 位数。
// CLR=1 时同步清零 ACC，优先级高于 EN。
// NRST=0 时异步清零 ACC，不等时钟上升沿。
// 8×8 位乘积为 16 位，ACC 额外留 4 位，宽度为 20 位；
// 连续累加 16 次极值乘积也不会溢出 20 位有符号范围。
// 这是 Module 5 点积、DSP 和矩阵运算的数据通路核心。
// ============================================================
module MAC (
    input  wire               CLK,
    input  wire               NRST,
    input  wire               CLR,
    input  wire               EN,
    input  wire signed [7:0]  A,
    input  wire signed [7:0]  B,
    output reg  signed [19:0] ACC
);
    wire signed [15:0] p     = $signed(A) * $signed(B);
    wire signed [19:0] p_ext = {{4{p[15]}}, p};      // 把 16 位乘积的符号位复制四次，符号扩展至 20 位后再累加。

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            ACC <= 20'sd0;
        else if (CLR)
            ACC <= 20'sd0;
        else if (EN)
            ACC <= ACC + p_ext;
    end
endmodule
