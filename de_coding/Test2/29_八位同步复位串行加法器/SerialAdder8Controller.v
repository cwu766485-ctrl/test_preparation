// 练习变体：8 位、低有效同步复位。与 28 号例题对照阅读。
module SerialAdder8Controller (
    input wire CLK,
    input wire NRST,
    input wire START,
    input wire [3:0] N,
    output wire LOAD,
    output wire STEP,
    output wire LAST,
    output reg [3:0] INDEX,
    output reg DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;
    reg state;
    reg [3:0] width_q;

    assign LOAD = (state == IDLE) && START;
    assign STEP = (state == RUN);
    assign LAST = STEP && (INDEX == width_q - 4'd1);

    // 同步复位：敏感列表只有 posedge CLK。
    always @(posedge CLK) begin
        if (!NRST) begin
            state   <= IDLE;
            width_q <= 4'd0;
            INDEX   <= 4'd0;
            DONE    <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    // 仅本练习约定：N=0 或 N>8 时按完整 8 位处理。
                    width_q <= (N == 4'd0 || N > 4'd8) ? 4'd8 : N;
                    INDEX   <= 4'd0;
                    state   <= RUN;
                end
                RUN: if (LAST) begin
                    state <= IDLE;
                    DONE  <= 1'b1;
                end else begin
                    INDEX <= INDEX + 4'd1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
