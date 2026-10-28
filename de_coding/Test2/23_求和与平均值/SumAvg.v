// 第23题：连续接收 N=8 个无符号 8 位数，每拍一个；START 与第一个数同拍，仅空闲时有效。
// 后续 N-1 拍不能留空；SUM 为总和，AVG 为向下取整的平均值，AVG_R 为四舍五入的平均值。
// 八个最大输入 255 的和是 2040，11 位足够；除以 8 相当于右移 3 位。
// 四舍五入先加 4 再右移 3 位；DONE 在第 N 个数处理完成时拉高一拍。
// 修改 N 时须同步修改 LOGN，且 N 应为 2 的幂。
module SumAvg #(
    parameter N    = 8,
    parameter LOGN = 3
) (
    input  wire              CLK,
    input  wire              NRST,
    input  wire              START,
    input  wire [7:0]        DIN,
    output reg  [7+LOGN:0]   SUM,
    output reg  [7:0]        AVG,
    output reg  [7:0]        AVG_R,
    output reg               DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg            state;
    reg [7+LOGN:0] acc;
    reg [LOGN:0]   cnt;                                  // 当前 DIN 对应本组第几个数

    wire [7+LOGN:0] acc_next = acc + {{LOGN{1'b0}}, DIN};
    wire [8+LOGN:0] rnd      = {1'b0, acc_next} + (1 << (LOGN - 1));   // 先加 N/2，使右移实现四舍五入

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;  acc <= 0;  cnt <= 0;
            SUM <= 0;  AVG <= 0;  AVG_R <= 0;  DONE <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    acc   <= {{LOGN{1'b0}}, DIN};        // 首个数直接写入累加器
                    cnt   <= 1;
                    state <= RUN;
                end
                RUN: begin
                    acc <= acc_next;
                    cnt <= cnt + 1'b1;
                    if (cnt == N - 1) begin              // 当前输入的是本组第 N 个数
                        SUM   <= acc_next;
                        AVG   <= acc_next[7+LOGN:LOGN];  // 右移 LOGN 位，相当于除以 N 并向下取整
                        AVG_R <= rnd[7+LOGN:LOGN];
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
