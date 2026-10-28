// 第27题：仿照第17题的可变位宽串行减法器，计算 A-B。
// START 在空闲时锁存两个操作数和位数 N；随后从最低位到最高位，每拍复用同一个 1 位减法器。
// borrow 保存上一位向本位借来的 1；当前差值位写入 DIFF[cnt]，并将 A/B 右移供下一拍使用。
// 第 N 拍结束时更新 BOUT（最终借位）并拉高 DONE 一拍；输入高于 N 位的部分不计入结果。
module SerialSubtractor #(
    parameter W = 16          // 此练习的 N 位宽和输入向量按 W=16 编写
) (
    input  wire         CLK,
    input  wire         NRST,       // 异步低电平有效复位
    input  wire         START,
    input  wire [W-1:0] A,
    input  wire [W-1:0] B,
    input  wire [4:0]   N,          // 有效范围 1～16；0 或超过 16 时按 16 位处理
    output reg  [W-1:0] DIFF,       // A-B 的低 N 位差值；高位保持为 0
    output reg          BOUT,       // 1 表示 A 的低 N 位小于 B 的低 N 位，即发生借位
    output reg          DONE        // 差值和借位有效时拉高一拍
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg         state;
    reg [W-1:0] a_sh, b_sh;
    reg         borrow;
    reg [4:0]   cnt, n_reg;

    // 一位减法：差值等于 A 位、B 位和输入借位三者的异或。
    // 借位条件：A 位为 0 且 B 位为 1；或本来有借位且 A、B 两位相同。
    wire d_bit = a_sh[0] ^ b_sh[0] ^ borrow;
    wire borrow_next = (~a_sh[0] & b_sh[0]) |
                       (borrow & ~(a_sh[0] ^ b_sh[0]));

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state  <= IDLE;
            a_sh   <= 0;
            b_sh   <= 0;
            borrow <= 1'b0;
            cnt    <= 0;
            n_reg  <= 0;
            DIFF   <= 0;
            BOUT   <= 1'b0;
            DONE   <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                // 空闲阶段：只在 START 有效时装入整字；清零旧结果以保证高位为 0。
                IDLE: if (START) begin
                    a_sh   <= A;
                    b_sh   <= B;
                    n_reg  <= (N == 5'd0 || N > W) ? W : N;
                    borrow <= 1'b0;
                    cnt    <= 0;
                    DIFF   <= 0;
                    BOUT   <= 1'b0;
                    state  <= RUN;
                end
                // 运行阶段：cnt=0 对应最低位；每拍只处理一个位并传播借位。
                RUN: begin
                    DIFF[cnt] <= d_bit;
                    borrow    <= borrow_next;
                    a_sh      <= a_sh >> 1;
                    b_sh      <= b_sh >> 1;
                    // 当前是第 N 位时，borrow_next 才是整个 N 位减法的最终借位。
                    if (cnt == n_reg - 5'd1) begin
                        BOUT  <= borrow_next;
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end else begin
                        cnt <= cnt + 5'd1;
                    end
                end
            endcase
        end
    end
endmodule
