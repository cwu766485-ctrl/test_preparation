// Parameterized Kogge-Stone prefix adder.
// Advantage: computes carries with logarithmic logic depth.
// Disadvantage: the dense prefix network uses more wiring and area than ripple carry.
module prefix_adder #(
    parameter integer WIDTH = 16
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);
    localparam integer LEVELS = (WIDTH <= 1) ? 0 : $clog2(WIDTH);

    wire [WIDTH-1:0] propagate [0:LEVELS];
    wire [WIDTH-1:0] gen_stage [0:LEVELS];
    wire [WIDTH-1:0] carry;

    assign propagate[0] = a ^ b;
    assign gen_stage[0] = a & b;
    assign carry[0]     = cin;

    genvar level;
    genvar carry_index;
    generate
        for (level = 0; level < LEVELS; level = level + 1) begin : PREFIX_LEVEL
            prefix_adder_stage #(
                .WIDTH    (WIDTH),
                .DISTANCE (1 << level)
            ) u_prefix_adder_stage (
                .propagate_in  (propagate[level]),
                .generate_in   (gen_stage[level]),
                .propagate_out (propagate[level+1]),
                .generate_out  (gen_stage[level+1])
            );
        end

        for (carry_index = 1; carry_index < WIDTH; carry_index = carry_index + 1) begin : FINAL_CARRY
            assign carry[carry_index] =
                gen_stage[LEVELS][carry_index-1] |
                (propagate[LEVELS][carry_index-1] & cin);
        end
    endgenerate

    assign sum  = propagate[0] ^ carry;
    assign cout = gen_stage[LEVELS][WIDTH-1] |
                  (propagate[LEVELS][WIDTH-1] & cin);
endmodule
