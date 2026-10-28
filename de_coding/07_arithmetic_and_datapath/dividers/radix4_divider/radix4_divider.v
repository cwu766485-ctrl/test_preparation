// Iterative unsigned radix-4 restoring divider.
// Advantage: selects two quotient bits per iteration, taking about WIDTH/2 iterations.
// Disadvantage: must compare against and subtract up to three times the divisor.
module radix4_divider #(
    parameter integer WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             start,
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    output reg  [WIDTH-1:0] quotient,
    output reg  [WIDTH-1:0] remainder,
    output reg              done,
    output reg              div_zero
);
    localparam integer PAD_WIDTH    = ((WIDTH + 1) / 2) * 2;
    localparam integer ITERATIONS   = PAD_WIDTH / 2;
    localparam integer COUNT_WIDTH  = (ITERATIONS <= 1) ? 1 : $clog2(ITERATIONS);
    localparam [COUNT_WIDTH-1:0] LAST_COUNT = ITERATIONS[COUNT_WIDTH-1:0] - 1'b1;

    reg                  busy;
    reg [PAD_WIDTH-1:0]  quotient_shift_reg;
    reg [WIDTH-1:0]      divisor_reg;
    reg [WIDTH-1:0]      remainder_reg;
    reg [COUNT_WIDTH-1:0] count;

    reg [WIDTH+1:0] trial_remainder;
    reg [WIDTH+1:0] divisor_extended;
    reg [WIDTH+1:0] divisor_twice;
    reg [WIDTH+1:0] divisor_thrice;
    reg [WIDTH-1:0] remainder_next;
    reg [1:0]       quotient_digit;
    reg [PAD_WIDTH-1:0] quotient_next;

    always @* begin
        trial_remainder = {remainder_reg[WIDTH-1:0],
                           quotient_shift_reg[PAD_WIDTH-1:PAD_WIDTH-2]};
        divisor_extended = {{2{1'b0}}, divisor_reg};
        divisor_twice = divisor_extended << 1;
        divisor_thrice = divisor_twice + divisor_extended;
        remainder_next = trial_remainder[WIDTH-1:0];
        quotient_digit = 2'b00;

        if (trial_remainder >= divisor_thrice) begin
            remainder_next = trial_remainder[WIDTH-1:0] - divisor_thrice[WIDTH-1:0];
            quotient_digit = 2'b11;
        end
        else if (trial_remainder >= divisor_twice) begin
            remainder_next = trial_remainder[WIDTH-1:0] - divisor_twice[WIDTH-1:0];
            quotient_digit = 2'b10;
        end
        else if (trial_remainder >= divisor_extended) begin
            remainder_next = trial_remainder[WIDTH-1:0] - divisor_extended[WIDTH-1:0];
            quotient_digit = 2'b01;
        end

        quotient_next = (quotient_shift_reg << 2) |
                        {{(PAD_WIDTH-2){1'b0}}, quotient_digit};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy      <= 1'b0;
            count     <= 0;
            divisor_reg <= 0;
            quotient_shift_reg <= 0;
            remainder_reg <= 0;
            quotient  <= 0;
            remainder <= 0;
            done      <= 1'b0;
            div_zero  <= 1'b0;
        end
        else begin
            done <= 1'b0;
            if (start && !busy) begin
                div_zero <= (divisor == 0);
                if (divisor == 0) begin
                    quotient  <= {WIDTH{1'b1}};
                    remainder <= dividend;
                    busy      <= 1'b0;
                    done      <= 1'b1;
                end
                else begin
                    busy <= 1'b1;
                    count <= 0;
                    divisor_reg <= divisor;
                    quotient_shift_reg <= {{(PAD_WIDTH-WIDTH){1'b0}}, dividend};
                    remainder_reg <= 0;
                end
            end
            else if (busy) begin
                quotient_shift_reg <= quotient_next;
                remainder_reg <= remainder_next;
                if (count == LAST_COUNT) begin
                    quotient <= quotient_next[WIDTH-1:0];
                    remainder <= remainder_next;
                    busy <= 1'b0;
                    done <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
