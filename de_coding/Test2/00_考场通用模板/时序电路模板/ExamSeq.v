// 考场时序电路模板：先锁存两个操作数，再每个时钟处理一位；算完后 DONE 拉高一个时钟周期。
// 默认示例计算低 N 位的逐位异或。考场需按题目修改标有“修改点”的地方，不能只改设计而忘记修改测试期望。
module ExamSeq (
    input  wire        CLK,
    input  wire        NRST,     // 修改点 1：核对题目的复位极性、端口名称和位宽；这里 NRST 为低电平有效。
    input  wire        START,
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire [4:0]  N,
    output reg  [15:0] RESULT,
    output reg         FLAG,
    output reg         DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;
    reg        state;
    reg [15:0] a_work, b_work;
    reg [4:0]  count, length;
    reg        bit_state;                  // 逐位处理时保存的状态位，可改作进位、借位或比较状态。

    // 修改点 2：按题意替换单个位的运算及状态位更新。
    // 当前默认是逐位异或；bit_state 一直为 0。
    // 若改成加法，当前结果位应为 A 位、B 位与旧进位的异或：result_bit = A_bit ^ B_bit ^ bit_state;
    // 加法的新进位第一部分：next_bit_state = (A_bit & B_bit) |
    // 加法的新进位第二部分： (bit_state & (A_bit ^ B_bit));
    wire result_bit = a_work[0] ^ b_work[0] ^ bit_state;
    wire next_bit_state = 1'b0;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state     <= IDLE;
            a_work    <= 0;
            b_work    <= 0;
            count     <= 0;
            length    <= 0;
            bit_state <= 0;
            RESULT    <= 0;
            FLAG      <= 0;
            DONE      <= 0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    // 修改点 3：START 在空闲状态被采样时装入输入、清零计数器；此例把 N=0 或 N>16 解释为 16 位。
                    a_work    <= A;
                    b_work    <= B;
                    length    <= (N == 0 || N > 16) ? 5'd16 : N;
                    count     <= 0;
                    bit_state <= 0;
                    RESULT    <= 0;
                    FLAG      <= 0;
                    state     <= RUN;
                end
                RUN: begin
                    // 修改点 4：RUN 状态每个上升沿写入一个结果位，保存新状态位并右移操作数；count 表示本拍处理的位号。
                    RESULT[count] <= result_bit;
                    bit_state     <= next_bit_state;
                    a_work        <= a_work >> 1;
                    b_work        <= b_work >> 1;
                    count         <= count + 5'd1;
                    if (count == length - 5'd1) begin
                        // 修改点 5：最后一位处理完的这个上升沿更新 FLAG、拉高 DONE，并返回空闲状态。
                        FLAG  <= next_bit_state;
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
