// ============================================================
// 第15题：输出 50% 占空比的 4 分频和 5 分频。4 分频直接取二位计数器最高位，输出每两拍翻转。5 分频计数 0 到 4；p 在输入时钟上升沿更新，n 在下降沿复制 p；p 或 n 合成高电平长度 2.5 个输入周期。
// ============================================================
module ClkDiv (
    input  wire CLK,
    input  wire NRST,
    output wire DIV4,
    output wire DIV5
);
    // 四分频：2 位计数器循环计数。
    reg [1:0] cnt4;
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) cnt4 <= 2'd0;
        else       cnt4 <= cnt4 + 2'd1;          // 计数序列为 0、1、2、3，再回到 0
    end
    assign DIV4 = cnt4[1];                       // 输出序列为 0、0、1、1；周期为 4 个输入周期，占空比 50%

    // 五分频：同时利用输入时钟上升沿和下降沿。
    reg [2:0] cnt5;
    reg       p, n;
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            cnt5 <= 3'd0;
            p    <= 1'b1;                        // 复位后 cnt5 为 0，因此 p 从高电平开始
        end else begin
            cnt5 <= (cnt5 == 3'd4) ? 3'd0 : cnt5 + 3'd1;
            p    <= (cnt5 == 3'd4) || (cnt5 == 3'd0);   // 根据旧 cnt5 计算；更新后 cnt5 为 0 或 1 时，p 为高
        end
    end
    always @(negedge CLK or negedge NRST) begin
        if (!NRST) n <= 1'b0;
        else       n <= p;                       // 下降沿复制 p，相对 p 延迟半个输入时钟周期
    end
    assign DIV5 = p | n;
endmodule
