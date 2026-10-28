// Fully pipelined unsigned restoring divider with one quotient-bit stage per bit.
// Advantage: accepts one input per cycle after pipeline fill.
// Disadvantage: uses WIDTH registered stages before producing each result.
module pipelined_divider #(
    parameter integer WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             valid_i,
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    output wire             valid_o,
    output wire [WIDTH-1:0] quotient,
    output wire [WIDTH-1:0] remainder,
    output wire             div_zero
);
    reg [WIDTH-1:0] remainder_pipe [0:WIDTH-1];
    reg [WIDTH-1:0] quotient_pipe  [0:WIDTH-1];
    reg [WIDTH-1:0] dividend_pipe  [0:WIDTH-1];
    reg [WIDTH-1:0] divisor_pipe   [0:WIDTH-1];
    reg             div_zero_pipe  [0:WIDTH-1];
    reg             valid_pipe     [0:WIDTH-1];

    assign valid_o  = valid_pipe[WIDTH-1];
    assign quotient = quotient_pipe[WIDTH-1];
    assign remainder = remainder_pipe[WIDTH-1];
    assign div_zero = div_zero_pipe[WIDTH-1];

    genvar stage;
    generate
        for (stage = 0; stage < WIDTH; stage = stage + 1) begin : DIVIDE_STAGE
            wire [WIDTH-1:0] remainder_in;
            wire [WIDTH-1:0] dividend_in;
            wire [WIDTH-1:0] quotient_in;
            wire [WIDTH-1:0] divisor_in;
            wire             div_zero_in;
            wire             valid_in;

            if (stage == 0) begin : FIRST_STAGE
                assign remainder_in = {WIDTH{1'b0}};
                assign dividend_in  = dividend;
                assign quotient_in  = {WIDTH{1'b0}};
                assign divisor_in   = divisor;
                assign div_zero_in  = (divisor == 0);
                assign valid_in     = valid_i;
            end
            else begin : LATER_STAGE
                assign remainder_in = remainder_pipe[stage-1];
                assign dividend_in  = dividend_pipe[stage-1];
                assign quotient_in  = quotient_pipe[stage-1];
                assign divisor_in   = divisor_pipe[stage-1];
                assign div_zero_in  = div_zero_pipe[stage-1];
                assign valid_in     = valid_pipe[stage-1];
            end

            wire [WIDTH:0] trial_remainder =
                {remainder_in[WIDTH-1:0], dividend_in[WIDTH-1]};
            wire subtract_enable = (trial_remainder >= {1'b0, divisor_in});
            wire [WIDTH-1:0] remainder_next = subtract_enable ?
                                              (trial_remainder[WIDTH-1:0] - divisor_in) :
                                              trial_remainder[WIDTH-1:0];
            wire [WIDTH-1:0] quotient_next = (quotient_in << 1) |
                                             {{(WIDTH-1){1'b0}}, subtract_enable};
            wire [WIDTH-1:0] dividend_next = dividend_in << 1;

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    remainder_pipe[stage] <= {WIDTH{1'b0}};
                    quotient_pipe[stage]  <= {WIDTH{1'b0}};
                    dividend_pipe[stage]  <= {WIDTH{1'b0}};
                    divisor_pipe[stage]   <= {WIDTH{1'b0}};
                    div_zero_pipe[stage]  <= 1'b0;
                    valid_pipe[stage]     <= 1'b0;
                end
                else begin
                    valid_pipe[stage]     <= valid_in;
                    if (valid_in) begin
                        remainder_pipe[stage] <= remainder_next;
                        quotient_pipe[stage]  <= quotient_next;
                        dividend_pipe[stage]  <= dividend_next;
                        divisor_pipe[stage]   <= divisor_in;
                        div_zero_pipe[stage]  <= div_zero_in;
                    end
                end
            end
        end
    endgenerate
endmodule
