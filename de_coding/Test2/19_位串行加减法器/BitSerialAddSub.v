// 第19题：位串行加减法器。A、B 每拍各输入一位，最低位先到；不是一次装入整字。
// FIRST 与新字最低位同时为 1，使本字从正确的初始进位开始；SUB 在一个字内保持不变。
// SUB=0 算 A+B，最低位进位为 0；SUB=1 算 A-B，即 A+(~B)+1，最低位进位为 1。
// S、CO 是当前输入位的组合输出：在当前上升沿之前就可读取；减法末位 CO=1 表示没有借位。
// carry 是唯一的状态寄存器；每个上升沿保存本位进位，供下一位使用。
module BitSerialAddSub (
    input  wire CLK,
    input  wire NRST,
    input  wire FIRST,
    input  wire SUB,
    input  wire A,
    input  wire B,
    output wire S,
    output wire CO
);
    reg  carry;                                   // 唯一的状态触发器，保存上一位进位

    wire b_eff  = B ^ SUB;                        // 减法时对 B 当前位取反
    wire c_in   = FIRST ? SUB : carry;            // 新字首位的初始进位：加法为 0，减法为 1

    assign S  = A ^ b_eff ^ c_in;                 // 一位全加器的和位公式
    assign CO = (A & b_eff) | (c_in & (A ^ b_eff));

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)
            carry <= 1'b0;
        else
            carry <= CO;                          // 上升沿保存本位进位，下一拍使用
    end
endmodule
