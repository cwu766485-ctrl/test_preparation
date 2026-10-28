// 第24题：连续 N=8 拍输入无符号 8 位 DIN；START 与首个数同拍，仅空闲时有效。
// 输出最大值 MAX、最小值 MIN，以及最大值第一次出现的位置 IMAX（从 0 开始）。
// 遇到相同最大值时不更新 IMAX，因为比较使用严格大于号；DONE 在第 N 个数处理后拉高一拍。
// 硬件由两个比较器、当前最大/最小寄存器和计数器组成；若改有符号数，比较方式也要调整。
module MaxMin #(
    parameter N    = 8,
    parameter LOGN = 3
) (
    input  wire            CLK,
    input  wire            NRST,
    input  wire            START,
    input  wire [7:0]      DIN,
    output reg  [7:0]      MAX,
    output reg  [7:0]      MIN,
    output reg  [LOGN-1:0] IMAX,
    output reg             DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;

    reg            state;
    reg [7:0]      cur_max, cur_min;         // 截至上一拍的最大值与最小值
    reg [LOGN-1:0] cur_imax;
    reg [LOGN:0]   cnt;                      // 当前 DIN 在本组中的位置

    // 把当前 DIN 纳入比较后的临时结果
    wire           new_max  = (DIN > cur_max);
    wire [7:0]     max_next = new_max ? DIN : cur_max;
    wire [7:0]     min_next = (DIN < cur_min) ? DIN : cur_min;
    wire [LOGN-1:0] imax_next = new_max ? cnt[LOGN-1:0] : cur_imax;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= IDLE;  cur_max <= 0;  cur_min <= 0;  cur_imax <= 0;  cnt <= 0;
            MAX <= 0;  MIN <= 0;  IMAX <= 0;  DONE <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    cur_max  <= DIN;                 // 首个数同时作为初始最大值和最小值
                    cur_min  <= DIN;
                    cur_imax <= 0;
                    cnt      <= 1;
                    state    <= RUN;
                end
                RUN: begin
                    cur_max  <= max_next;
                    cur_min  <= min_next;
                    cur_imax <= imax_next;
                    cnt      <= cnt + 1'b1;
                    if (cnt == N - 1) begin          // 本组最后一个输入值
                        MAX   <= max_next;
                        MIN   <= min_next;
                        IMAX  <= imax_next;
                        DONE  <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
