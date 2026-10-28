// 第22题：2×2 有符号矩阵乘 2×1 向量；Y0=M00*X0+M01*X1，Y1=M10*X0+M11*X1。
// A、B 共用两条 8 位输入总线，每拍输入一对；每次运算固定四拍。
// cnt=0 输入 M00/X0；cnt=1 输入 M01/X1，得到第一行；cnt=2 输入 M10/X0；cnt=3 输入 M11/X1。
// START 在空闲状态标记第一对输入；启动后持续每四拍完成一次，直到复位。
// 只用一个乘法器和一个累加器复用四次；结果扩展为有符号 17 位，OUT_STROBE 完成时拉高一拍。
module MatVec2x2 (
    input  wire               CLK,
    input  wire               NRST,
    input  wire               START,
    input  wire signed [7:0]  A,
    input  wire signed [7:0]  B,
    output reg  signed [16:0] Y0,
    output reg  signed [16:0] Y1,
    output reg                OUT_STROBE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg               state;
    reg        [1:0]  cnt;
    reg signed [16:0] acc;
    reg signed [16:0] y0_tmp;                       // 暂存第一行结果，等待第二行结果完成

    wire               active = (state == RUN) || START;
    wire signed [15:0] p      = $signed(A) * $signed(B);
    wire signed [16:0] p_ext  = {p[15], p};          // 保留符号位，将 16 位乘积扩成 17 位
    wire signed [16:0] base   = (cnt == 2'd0 || cnt == 2'd2) ? 17'sd0 : acc;   // 开始新的一行时累加器从 0 起算
    wire signed [16:0] sum    = base + p_ext;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;  cnt <= 0;  acc <= 0;  y0_tmp <= 0;
            Y0 <= 0;  Y1 <= 0;  OUT_STROBE <= 1'b0;
        end else begin
            OUT_STROBE <= 1'b0;
            if (active) begin
                state <= RUN;
                acc   <= sum;
                cnt   <= cnt + 2'd1;                 // 两位计数器从 3 加 1 自动回到 0
                if (cnt == 2'd1)
                    y0_tmp <= sum;                   // 第一行两项乘积累加完成
                if (cnt == 2'd3) begin               // 第二行两项乘积累加完成
                    Y0         <= y0_tmp;
                    Y1         <= sum;
                    OUT_STROBE <= 1'b1;
                end
            end
        end
    end
endmodule
