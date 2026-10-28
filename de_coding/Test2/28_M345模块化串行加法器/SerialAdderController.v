// M4: 控制器只决定何时装载、何时处理一位、何时结束。
// START 在 IDLE 的上升沿被接受；之后连续运行 N 个上升沿。
module SerialAdderController (
    input  wire       CLK,
    input  wire       NRST,
    input  wire       START,
    input  wire [4:0] N,
    output wire       LOAD,
    output wire       STEP,
    output wire       LAST,
    output reg  [4:0] INDEX,
    output reg        DONE
);
    localparam IDLE = 1'b0, RUN = 1'b1;
    reg state;
    reg [4:0] width_q;

    assign LOAD = (state == IDLE) && START;
    assign STEP = (state == RUN);
    assign LAST = STEP && (INDEX == width_q - 5'd1);

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state   <= IDLE;
            width_q <= 5'd0;
            INDEX   <= 5'd0;
            DONE    <= 1'b0;
        end else begin
            DONE <= 1'b0;
            case (state)
                IDLE: if (START) begin
                    // 0 或大于 16 的 N 按完整 16 位处理。
                    width_q <= (N == 5'd0 || N > 5'd16) ? 5'd16 : N;
                    INDEX   <= 5'd0;
                    state   <= RUN;
                end
                RUN: if (LAST) begin
                    state <= IDLE;
                    DONE  <= 1'b1;
                end else begin
                    INDEX <= INDEX + 5'd1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
