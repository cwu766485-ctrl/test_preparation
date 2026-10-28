// ============================================================
// 第17题：可变位宽串行加法器。START 在空闲态上升沿装入 A、B、N；忙时忽略 START。RUN 阶段每拍只用一个 1 位全加器处理当前最低位，并保存进位，直到计算完 N 位。SUM 的有效结果对齐低位，COUT 是最高有效位的进位，DONE 在最后一位计算后拉高一拍。N=0 或超出 W 时按 W 位处理。
// ============================================================
module SerialAdder #(
    parameter W = 16                       // 参数 W 决定允许的最大运算位宽
) (
    input  wire         CLK,
    input  wire         NRST,
    input  wire         START,
    input  wire [W-1:0] A,
    input  wire [W-1:0] B,
    input  wire [4:0]   N,                 // 有效运算位宽为 1 到 16
    output reg  [W-1:0] SUM,
    output reg          COUT,
    output reg          DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg         state;
    reg [W-1:0] a_sh, b_sh;                // 操作数副本每拍右移一位，把下一位移到最低位
    reg         carry;                     // 保存本位产生的进位，供下一拍计算更高位
    reg [4:0]   cnt;                       // 当前处理的位序号，从 0 到 N-1
    reg [4:0]   n_reg;                     // START 时锁存的位宽，运算期间输入 N 再变化也不会影响

    // 复用的单个 1 位全加器：当前 A、B 位与进位一起求和。
    wire s_bit = a_sh[0] ^ b_sh[0] ^ carry;
    wire c_bit = (a_sh[0] & b_sh[0]) | (carry & (a_sh[0] ^ b_sh[0]));

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;
            a_sh  <= 0;  b_sh <= 0;  carry <= 1'b0;
            cnt   <= 0;  n_reg <= 0;
            SUM   <= 0;  COUT <= 1'b0;  DONE <= 1'b0;
        end else begin
            DONE <= 1'b0;                          // 每拍先默认拉低 DONE，仅结束时覆盖为 1，形成单拍脉冲
            case (state)
                IDLE: if (START) begin
                    a_sh  <= A;
                    b_sh  <= B;
                    n_reg <= (N == 5'd0 || N > W) ? W : N;   // N 为 0 或超过最大值时，改用完整位宽 W
                    carry <= 1'b0;                 // 最低位没有来自更低位的进位，初值为 0
                    cnt   <= 0;
                    SUM   <= 0;                    // 启动时清空 SUM，因此未计算的高位保持 0
                    state <= RUN;
                end
                RUN: begin
                    SUM[cnt] <= s_bit;             // 把当前和位写回原来的位序号，使结果从最低位对齐
                    carry    <= c_bit;
                    a_sh     <= a_sh >> 1;         // 操作数右移后，下一位来到最低位供下一拍计算
                    b_sh     <= b_sh >> 1;
                    if (cnt == n_reg - 5'd1) begin // 当前已处理到最高有效位，保存最终进位并结束
                        COUT  <= c_bit;
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end else
                        cnt <= cnt + 5'd1;
                end
            endcase
        end
    end
endmodule
