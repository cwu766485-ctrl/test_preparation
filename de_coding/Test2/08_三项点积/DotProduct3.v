// ============================================================
// 第 8 题：三项点积，由 Module 5 的两项运算扩展而来。
// OUT=A2×B2+A1×B1+A0×B0；A、B 是有符号 8 位数。
// 三组操作数连续三拍复用同一组 A/B 输入总线。
// 空闲时 START 与 A2/B2 同拍到来，启动第一项计算；随后
// 电路持续运行，每三拍形成下一组结果，直至 NRST 复位。
// 数据通路是乘法加累加；2 位计数器 cnt 标记第 0、1、2 项。
// cnt=0：丢弃上一组累加值，从 0+A×B 开始。
// cnt=1：把第二项 A×B 加到 acc。
// cnt=2：第三项加完直接写 OUT，OUT_STROBE 拉高一拍。
// 每项乘积 16 位；三项求和多留 2 位，共用 18 位有符号结果。
// ============================================================
module DotProduct3 (
    input  wire               CLK,
    input  wire               NRST,
    input  wire               START,
    input  wire signed [7:0]  A,
    input  wire signed [7:0]  B,
    output reg  signed [17:0] OUT,
    output reg                OUT_STROBE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg               state;
    reg        [1:0]  cnt;                  // cnt 指示当前总线上是本组第几项，取值 0、1、2。
    reg signed [17:0] acc;

    wire               active = (state == RUN) || START;     // 运行中始终有效；空闲时 START=1 也要立刻处理第一项。
    wire signed [15:0] p      = $signed(A) * $signed(B);
    wire signed [17:0] p_ext  = {{2{p[15]}}, p};             // 把 16 位有符号乘积的符号位复制两次，扩成 18 位。
    wire signed [17:0] base   = (cnt == 2'd0) ? 18'sd0 : acc;
    wire signed [17:0] sum    = base + p_ext;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state      <= IDLE;
            cnt        <= 2'd0;
            acc        <= 18'sd0;
            OUT        <= 18'sd0;
            OUT_STROBE <= 1'b0;
        end else begin
            OUT_STROBE <= 1'b0;                 // 每拍先默认清零，使 OUT_STROBE 只持续一个周期。
            if (active) begin
                state <= RUN;
                acc   <= sum;
                if (cnt == 2'd2) begin
                    OUT        <= sum;          // 第三项加入后直接公布完整结果。
                    OUT_STROBE <= 1'b1;
                    cnt        <= 2'd0;
                end else
                    cnt <= cnt + 2'd1;
            end
        end
    end
endmodule
