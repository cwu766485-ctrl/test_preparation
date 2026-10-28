module seq_1011 (
    input  logic clk,
    input  logic rst_n,
    input  logic data,
    output logic det
);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S0;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
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
