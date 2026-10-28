// 第25题：主路与支路交通灯控制器。CAR=1 表示支路有车等待，是电平信号。
// MAIN、SIDE 各用 {红,黄,绿} 三个位编码；每条路同一时刻只能亮一盏灯。
// 四状态 Moore 状态机：MG 主绿支红至少 T_MG 拍，有车才转 MY；MY 主黄支红 T_Y 拍；
// SG 主红支绿 T_SG 拍；SY 主红支黄 T_Y 拍，之后回 MG。两路绝不同时非红。
// 参数是仿真用的短拍数；真实按秒控制还需要较慢的计时脉冲或分频计数。
module TrafficLight #(
    parameter T_MG = 6,          // 主路绿灯最短持续拍数
    parameter T_Y  = 2,          // 黄灯持续拍数
    parameter T_SG = 4           // 支路绿灯持续拍数
) (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       CAR,
    output reg  [2:0] MAIN,      // 位序依次为红、黄、绿
    output reg  [2:0] SIDE
);
    localparam MG = 2'd0, MY = 2'd1, SG = 2'd2, SY = 2'd3;
    localparam RED = 3'b100, YELLOW = 3'b010, GREEN = 3'b001;

    reg [1:0] state, next_state;
    reg [3:0] timer;                             // 当前相位已持续的拍数减 1

    // 第一部分：状态寄存器和相位计时器
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state <= MG;
            timer <= 0;
        end else begin
            state <= next_state;
            if (next_state != state)
                timer <= 0;                      // 切换到新相位时重新计时
            else if (timer != 4'hF)
                timer <= timer + 4'd1;           // 到最大值后保持，避免计数回绕
        end
    end

    // 第二部分：计算下一相位
    always @(*) begin
        next_state = state;                      // 默认留在当前相位
        case (state)
            MG: if (timer >= T_MG - 1 && CAR) next_state = MY;
            MY: if (timer == T_Y  - 1)        next_state = SG;
            SG: if (timer == T_SG - 1)        next_state = SY;
            SY: if (timer == T_Y  - 1)        next_state = MG;
        endcase
    end

    // 第三部分：Moore 输出只由当前状态决定
    always @(*) begin
        case (state)
            MG:      begin MAIN = GREEN;  SIDE = RED;    end
            MY:      begin MAIN = YELLOW; SIDE = RED;    end
            SG:      begin MAIN = RED;    SIDE = GREEN;  end
            default: begin MAIN = RED;    SIDE = YELLOW; end   // 支路黄灯状态
        endcase
    end
endmodule
