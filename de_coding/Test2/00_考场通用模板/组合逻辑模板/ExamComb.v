// 考场组合逻辑模板：输出只由当前输入决定，没有时钟和内部状态。
// 默认示例为 8 位异或；结果等于零时 FLAG 为 1。
module ExamComb (
    input  wire [7:0] A,             // 修改点 1：按题目调整输入输出端口及位宽。
    input  wire [7:0] B,
    output reg  [7:0] RESULT,
    output reg        FLAG
);
    always @(*) begin
        // 修改点 2：保证每一种输入情况下，每个输出都被赋值。
        // 先给默认值可防止添加分支后漏赋值，从而意外综合出锁存器。
        RESULT = 8'b0;
        FLAG   = 1'b0;

        RESULT = A ^ B;               // 将这里的异或表达式改为题目的组合运算。
        FLAG   = (RESULT == 8'b0);   // 将这里的零检测改为题目规定的标志条件。
    end
endmodule
