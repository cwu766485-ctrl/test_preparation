

module seq_1011 (
    input wire clk,
    input wire rst_n,
    input wire data,
    output reg det
);

        localparam [2:0] S0 = 0;
    localparam [2:0] S1 = (0) + 1'b1;
    localparam [2:0] S2 = ((0) + 1'b1) + 1'b1;
    localparam [2:0] S3 = (((0) + 1'b1) + 1'b1) + 1'b1;
    localparam [2:0] S4 = ((((0) + 1'b1) + 1'b1) + 1'b1) + 1'b1;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.

    reg [2:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
        end
        else begin
            state <= next_state;
        end
    end

    always @* begin
        next_state = S0;
        det        = 1'b0;

        case (state)
            S0: next_state = data ? S1 : S0;
            S1: next_state = data ? S1 : S2;
            S2: next_state = data ? S3 : S0;
            S3: next_state = data ? S4 : S2;
            S4: begin
                det        = data;
                next_state = data ? S1 : S2;
            end
            default: next_state = S0;
        endcase
    end

endmodule