// Four-state example FSM with registered sum/carry outputs.
module state_machine_regout (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire state_reset,
    input  wire a,
    input  wire b,
    input  wire cin,
    output reg  sum_out,
    output reg  carry_out
);
    localparam [1:0] S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
    reg [1:0] state, next_state;

    always @* begin
        next_state = state;
        case (state)
            S0: next_state = start ? S1 : S0;
            S1: next_state = state_reset ? S0 : S2;
            S2: next_state = state_reset ? S0 : S3;
            S3: next_state = state_reset ? S0 : S1;
            default: next_state = S0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S0;
            sum_out  <= 1'b0;
            carry_out <= 1'b0;
        end else begin
            state <= next_state;
            // Decode the old state and register the result at this edge.
            case (state)
                S1: begin sum_out <= a ^ b ^ cin; carry_out <= 1'b0; end
                S2: begin sum_out <= 1'b0; carry_out <= (a & b) | (a & cin) | (b & cin); end
                S3: begin sum_out <= a ^ b ^ cin; carry_out <= (a & b) | (a & cin) | (b & cin); end
                default: begin sum_out <= 1'b0; carry_out <= 1'b0; end
            endcase
        end
    end
endmodule
