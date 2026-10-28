// 1 位全加器：S 为 A、B、CIN 三个输入相加后的最低位；COUT 为进位。与 Module 3 的电路相同。
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
