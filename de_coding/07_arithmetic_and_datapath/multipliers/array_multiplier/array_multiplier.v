// Unsigned array multiplier built from partial products and a full-adder array.
// Advantage: the repeated adder cells form a regular, easy-to-inspect structure.
// Disadvantage: it uses many full adders and has a long combinational path.
module array_multiplier #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [2*WIDTH-1:0] product
);
    wire [2*WIDTH-1:0] partial_product [0:WIDTH-1];
    wire [2*WIDTH-1:0] partial_sum     [0:WIDTH];

    assign partial_sum[0] = {2*WIDTH{1'b0}};

    genvar row;
    generate
        for (row = 0; row < WIDTH; row = row + 1) begin : PP_ROW
            assign partial_product[row] =
                {{WIDTH{1'b0}}, (a & {WIDTH{b[row]}})} << row;
            ripple_carry_adder #(
                .WIDTH (2*WIDTH)
            ) u_row_adder (
                .a    (partial_sum[row]),
                .b    (partial_product[row]),
                .cin  (1'b0),
                .sum  (partial_sum[row+1]),
                // Every intermediate sum is a subset of the full product and fits 2*WIDTH bits.
                /* verilator lint_off PINCONNECTEMPTY */
                .cout ()
                /* verilator lint_on PINCONNECTEMPTY */
            );
        end
    endgenerate

    assign product = partial_sum[WIDTH];
endmodule
