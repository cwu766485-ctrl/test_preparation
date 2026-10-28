// ============================================================
// 改错题 3：规格为 {COUT,S}=A+B+CIN，其中 A、B 是 4 位无符号数。这里故意先把结果截为 4 位，再用截断后的 sum 判断进位；sum 永远不可能大于 15，因此 COUT 错误。用 Adder4_tb.v 与 InputVector.txt 找出进位不一致的向量。
// ============================================================
module Adder4 (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       CIN,
    output wire [3:0] S,
    output wire       COUT
);
    wire [3:0] sum = A + B + CIN; // 故意保留：此处位宽不足，最高进位已经丢失。

    assign S    = sum;
    assign COUT = (sum > 4'd15);
endmodule
