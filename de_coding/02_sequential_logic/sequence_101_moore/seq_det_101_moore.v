// Moore FSM that detects the serial pattern 101, including overlapping matches.
module seq_det_101_moore (
    input  wire clk,
    input  wire rst_n,
    input  wire din,
    output wire detected
);
    localparam [1:0] S0   = 2'd0;
    localparam [1:0] S1   = 2'd1;
    localparam [1:0] S10  = 2'd2;
    localparam [1:0] S101 = 2'd3;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    always @* begin
        next_state = S0;
        case (state)
            S0:   next_state = din ? S1 : S0;
            S1:   next_state = din ? S1 : S10;
            S10:  next_state = din ? S101 : S0;
            // Preserve the longest useful suffix after a match.
            S101: next_state = din ? S1 : S10;
            default: next_state = S0;
        endcase
    end

    assign detected = (state == S101);
endmodule
