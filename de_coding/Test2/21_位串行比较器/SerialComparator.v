// 第21题：无符号位串行比较器。每拍输入 A、B 各一位，最高位先到；FIRST 与新字最高位同时为 1。
// 从高位往低位看，最先不相同的一位就决定大小，后续低位不再改变比较结果。
// 三个状态：S_EQ 表示目前相等，S_GT 表示 A 已确定较大，S_LT 表示 B 已确定较大。
// FIRST 开始新字时重新比较本位；最后一位的上升沿之后，GT/EQ/LT 指示整字结果。
// 输出只由寄存器状态决定，是 Moore 型状态机。
module SerialComparator (
    input  wire CLK,
    input  wire NRST,
    input  wire FIRST,
    input  wire A,
    input  wire B,
    output wire GT,
    output wire EQ,
    output wire LT
);
    localparam S_EQ = 2'b00, S_GT = 2'b01, S_LT = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) state <= S_EQ;
        else       state <= next_state;
    end

    always @(*) begin
        if (FIRST || state == S_EQ) begin          // 尚未决定大小，或 FIRST 表示新字开始
            if (A & ~B)       next_state = S_GT;
            else if (~A & B)  next_state = S_LT;
            else              next_state = S_EQ;
        end else
            next_state = state;                    // 大小已确定，后续低位不改变结果
    end

    assign GT = (state == S_GT);
    assign LT = (state == S_LT);
    assign EQ = (state == S_EQ);
endmodule
