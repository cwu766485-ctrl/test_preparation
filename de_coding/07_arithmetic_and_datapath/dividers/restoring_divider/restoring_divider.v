// Iterative unsigned restoring divider.
// Advantage: simple, deterministic WIDTH-cycle implementation.
// Disadvantage: one quotient bit per cycle and relatively low throughput.
module restoring_divider #(
    parameter integer WIDTH = 8
) (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               start,
    input  wire [WIDTH-1:0]   dividend,
    input  wire [WIDTH-1:0]   divisor,
    output reg  [WIDTH-1:0]   quotient,
    output reg  [WIDTH-1:0]   remainder,
    output reg                busy,
    output reg                done,
    output reg                div_zero
);
    localparam integer COUNT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH);
    localparam [COUNT_WIDTH-1:0] LAST_COUNT = WIDTH[COUNT_WIDTH-1:0] - 1'b1;

    reg [WIDTH-1:0] divisor_reg;
    reg [WIDTH-1:0] quotient_reg;
    reg [WIDTH-1:0] remainder_reg;
    reg [COUNT_WIDTH-1:0] count;

    wire [WIDTH:0] trial_remainder = {remainder_reg, quotient_reg[WIDTH-1]};
    wire           subtract_enable = (trial_remainder >= {1'b0, divisor_reg});
    wire [WIDTH-1:0] remainder_next = subtract_enable ?
                                      (trial_remainder[WIDTH-1:0] - divisor_reg) :
                                      trial_remainder[WIDTH-1:0];
    wire [WIDTH-1:0] quotient_next = (quotient_reg << 1) |
                                     {{(WIDTH-1){1'b0}}, subtract_enable};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            divisor_reg    <= 0;
            quotient_reg   <= 0;
            remainder_reg  <= 0;
            count          <= 0;
            quotient       <= 0;
            remainder      <= 0;
            busy           <= 1'b0;
            done           <= 1'b0;
            div_zero       <= 1'b0;
        end
        else begin
            done <= 1'b0;

            if (start && !busy) begin
                div_zero <= (divisor == 0);

                if (divisor == 0) begin
                    quotient <= {WIDTH{1'b1}};
                    remainder <= dividend;
                    done <= 1'b1;
                end
                else begin
                    divisor_reg   <= divisor;
                    quotient_reg  <= dividend;
                    remainder_reg <= 0;
                    count         <= 0;
                    busy          <= 1'b1;
                end
            end
            else if (busy) begin
                remainder_reg <= remainder_next;
                quotient_reg  <= quotient_next;

                if (count == LAST_COUNT) begin
                    quotient  <= quotient_next;
                    remainder <= remainder_next;
                    busy      <= 1'b0;
                    done      <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
