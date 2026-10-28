
module fsm_3seg (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    output logic [1:0] out
);

    typedef enum logic [1:0] {
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10
    } state_t;

    state_t state, next_state;

    // 1. State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    // 2. Next-state logic
    always_comb begin
        next_state = state;

        case (state)
            S0: if (start)
                    next_state = S1;

            S1: next_state = S2;
            S2: next_state = S0;

            default: next_state = S0;
        endcase
    end

    // 3. Output logic (Moore)
    always_comb begin
        out = 2'b00;

        case (state)
            S0: out = 2'b00;
            S1: out = 2'b01;
            S2: out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule
