// Unsigned Wallace multiplier using carry-save compression stages and a final adder.
// Advantage: partial-product rows are reduced in a tree instead of a long adder chain.
// Disadvantage: the compressor tree uses substantial wiring and can increase routing cost.
module wallace_multiplier #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0]   a,
    input  wire [WIDTH-1:0]   b,
    output wire [2*WIDTH-1:0] product
);
    localparam integer ROW_WIDTH = 2 * WIDTH;
    wire [WIDTH*ROW_WIDTH-1:0] partial_products;
    wire [ROW_WIDTH-1:0] final_row_0;
    wire [ROW_WIDTH-1:0] final_row_1;

    genvar pp_index;
    generate
        for (pp_index = 0; pp_index < WIDTH; pp_index = pp_index + 1) begin : PARTIAL_PRODUCTS
            assign partial_products[pp_index*ROW_WIDTH +: ROW_WIDTH] =
                {{WIDTH{1'b0}}, (a & {WIDTH{b[pp_index]}})} << pp_index;
        end
    endgenerate

    wallace_compressor_tree #(
        .ROW_WIDTH (ROW_WIDTH),
        .ROWS      (WIDTH)
    ) u_wallace_compressor_tree (
        .rows   (partial_products),
        .row_0  (final_row_0),
        .row_1  (final_row_1)
    );

    assign product = final_row_0 + final_row_1;
endmodule
