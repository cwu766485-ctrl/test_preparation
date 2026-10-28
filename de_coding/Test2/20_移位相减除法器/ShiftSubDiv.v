// 第20题：无符号移位相减除法器。A 是被除数，B 是除数；Q=A/B，R=A%B。
// START 仅在空闲时接受，同时锁存 A、B；运行中 START 无效。此后逐拍处理 A 的位，从最高位开始。
// 每拍将旧余数左移并移入下一位，得到 trial；若 trial>=B，就减去 B，商该位为 1；否则余数保持，商该位为 0。
// 全程只复用一个减法器；处理 W 位后输出 Q、R、DIV0，并将 DONE 拉高一拍。
// B=0 时该算法得到全 1 的商和等于 A 的余数，同时 DIV0=1；START 到 DONE 相隔 W+1 拍。
module ShiftSubDiv #(
    parameter W = 8
) (
    input  wire         CLK,
    input  wire         NRST,
    input  wire         START,
    input  wire [W-1:0] A,
    input  wire [W-1:0] B,
    output reg  [W-1:0] Q,
    output reg  [W-1:0] R,
    output reg          DIV0,
    output reg          DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg         state;
    reg [W-1:0] rem;        // 逐拍部分余数；除数非零时小于 B，W 位足够
    reg [W-1:0] qa;         // 先装入 A，左移时从最高位依次取出被除数位，
                            // 新商位从最低位逐步移入
    reg [W-1:0] divisor;
    reg [4:0]   cnt;

    wire [W:0] trial = {rem, qa[W-1]};             // 余数左移，并带下一个被除数位
    wire       ge    = (trial >= {1'b0, divisor});  // 试余数是否足够减去除数
    wire [W:0] diff  = trial - {1'b0, divisor};     // 整个数据通路复用的减法器

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;  rem <= 0;  qa <= 0;  divisor <= 0;  cnt <= 0;
            Q <= 0;  R <= 0;  DIV0 <= 1'b0;  DONE <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    rem     <= 0;
                    qa      <= A;
                    divisor <= B;
                    cnt     <= 0;
                    state   <= RUN;
                end
                RUN: begin
                    rem <= ge ? diff[W-1:0] : trial[W-1:0];
                    qa  <= {qa[W-2:0], ge};             // 左移并把当前算出的商位放到最低位
                    if (cnt == W - 1) begin
                        Q     <= {qa[W-2:0], ge};
                        R     <= ge ? diff[W-1:0] : trial[W-1:0];
                        DIV0  <= (divisor == 0);
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end else
                        cnt <= cnt + 5'd1;
                end
            endcase
        end
    end
endmodule
