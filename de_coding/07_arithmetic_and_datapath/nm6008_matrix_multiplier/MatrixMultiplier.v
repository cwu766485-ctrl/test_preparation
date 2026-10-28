// NM6008 Module 5 matrix multiplier example.
// Each result is A1*B1 + A0*B0. The signed 8-bit input buses carry one
// operand pair per cycle; one product register is reused for every result.
module MatrixMultiplier (
    input  wire               CLK,
    input  wire               NRST,
    input  wire               START,
    input  wire signed [7:0]  A,
    input  wire signed [7:0]  B,
    output reg  signed [16:0] OUT,
    output reg                OUT_STROBE
);
    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] FIRST = 2'b01;
    localparam [1:0] SECOND = 2'b10;

    reg [1:0] state;
    reg signed [15:0] product_q;
    reg signed [16:0] accumulator_q;

    // State-machine enables corresponding to the three blocks in the manual.
    wire EN1 = (state == FIRST);
    wire EN2 = (state == SECOND);
    wire EN3 = (state == SECOND);

    wire signed [15:0] product_now = $signed(A) * $signed(B);
    wire signed [16:0] product_q_ext = {product_q[15], product_q};
    wire signed [16:0] product_now_ext = {product_now[15], product_now};
    wire signed [16:0] sum_next = product_q_ext + product_now_ext;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            state        <= IDLE;
            product_q   <= 16'sd0;
            accumulator_q <= 17'sd0;
            OUT          <= 17'sd0;
            OUT_STROBE   <= 1'b0;
        end else begin
            OUT_STROBE <= 1'b0;
            case (state)
                IDLE: begin
                    if (START) begin
                        state <= FIRST;
                    end
                end
                FIRST: begin
                    // EN1: register the first signed product.
                    if (EN1)
                        product_q <= product_now;
                    state <= SECOND;
                end
                SECOND: begin
                    // EN2/EN3: accumulate both sign-extended products and
                    // publish one valid result. Then accept the next pair.
                    if (EN2)
                        accumulator_q <= sum_next;
                    if (EN3) begin
                        OUT <= sum_next;
                        OUT_STROBE <= 1'b1;
                    end
                    state <= FIRST;
                end
                default: begin
                    state <= IDLE;
                    product_q <= 16'sd0;
                    accumulator_q <= 17'sd0;
                    OUT <= 17'sd0;
                    OUT_STROBE <= 1'b0;
                end
            endcase
        end
    end
endmodule
