// 1 位全加器，与 Module 3 的基础电路相同：S 是和位，COUT 是向高位传递的进位。
module FullAdder (
    input  wire A,
    input  wire B,
    input  wire CIN,
    output wire S,
    output wire COUT
);
    assign S    = A ^ B ^ CIN;
    assign COUT = (A & B) | (CIN & (A ^ B));
endmodule
