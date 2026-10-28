// 第 1 题：用四个 1 位全加器串接，构成 4 位脉动进位加法器。
// 顶层模块名为 Adder4；综合脚本中指定的顶层名称也必须一致。
module Adder4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       CIN,
    output wire [3:0] S,
    output wire       COUT
);
    wire [3:0] c;   // c[0] 至 c[3] 分别是第 0 至第 3 位产生的进位；后一位用前一位的进位作输入。

    FullAdder FA0 (.A(A[0]), .B(B[0]), .CIN(CIN ), .S(S[0]), .COUT(c[0]));
    FullAdder FA1 (.A(A[1]), .B(B[1]), .CIN(c[0]), .S(S[1]), .COUT(c[1]));
    FullAdder FA2 (.A(A[2]), .B(B[2]), .CIN(c[1]), .S(S[2]), .COUT(c[2]));
    FullAdder FA3 (.A(A[3]), .B(B[3]), .CIN(c[2]), .S(S[3]), .COUT(c[3]));

    assign COUT = c[3];

    // 等价的行为级写法如下，也可以综合；本题保留结构化实例以观察逐级进位。
    // assign {COUT, S} = A + B + CIN;
endmodule
