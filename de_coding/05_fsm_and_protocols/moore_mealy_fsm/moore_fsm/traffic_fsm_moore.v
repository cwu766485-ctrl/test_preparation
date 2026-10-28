

module traffic_fsm (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg [1:0] out
);

        localparam [1:0] IDLE = 0;
    localparam [1:0] RUN = (0) + 1'b1;
    localparam [1:0] DONE = ((0) + 1'b1) + 1'b1;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @* begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = RUN;
                end
            end
            RUN: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @* begin
        case (state)
            IDLE:    out = 2'b00;
            RUN:     out = 2'b01;
            DONE:    out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule