

module seq_detect_101 (
    input wire clk,
    input wire rst_n,
    input wire data,
    output reg flag
);

        localparam [1:0] IDLE = 0;
    localparam [1:0] GOT_1 = (0) + 1'b1;
    localparam [1:0] GOT_10 = ((0) + 1'b1) + 1'b1;
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
        flag       = 1'b0;

        case (state)
            IDLE: begin
                next_state = data ? GOT_1 : IDLE;
            end
            GOT_1: begin
                next_state = data ? GOT_1 : GOT_10;
            end
            GOT_10: begin
                if (data) begin
                    next_state = GOT_1;
                    flag       = 1'b1;
                end
                else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule