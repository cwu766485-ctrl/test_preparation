


module fsm_3seg (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg [1:0] out
);

        localparam [1:0] S0 = 2'b00;
    localparam [1:0] S1 = 2'b01;
    localparam [1:0] S2 = 2'b10;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.

    reg [1:0] state, next_state;

    // 1. State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    // 2. Next-state reg
    always @* begin
        next_state = state;

        case (state)
            S0: if (start)
                    next_state = S1;

            S1: next_state = S2;
            S2: next_state = S0;

            default: next_state = S0;
        endcase
    end

    // 3. Output reg (Moore)
    always @* begin
        out = 2'b00;

        case (state)
            S0: out = 2'b00;
            S1: out = 2'b01;
            S2: out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule