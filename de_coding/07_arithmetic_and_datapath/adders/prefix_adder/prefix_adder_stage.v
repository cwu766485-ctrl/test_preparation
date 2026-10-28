// One Kogge-Stone prefix stage at a compile-time distance.
module prefix_adder_stage #(
    parameter integer WIDTH    = 16,
    parameter integer DISTANCE = 1
) (
    input  wire [WIDTH-1:0] propagate_in,
    input  wire [WIDTH-1:0] generate_in,
    output wire [WIDTH-1:0] propagate_out,
    output wire [WIDTH-1:0] generate_out
);
    genvar bit_index;
    generate
        for (bit_index = 0; bit_index < WIDTH; bit_index = bit_index + 1) begin : PREFIX_BIT
            if (bit_index >= DISTANCE) begin : COMBINE
                assign generate_out[bit_index] =
                    generate_in[bit_index] |
                    (propagate_in[bit_index] & generate_in[bit_index-DISTANCE]);
                assign propagate_out[bit_index] =
                    propagate_in[bit_index] & propagate_in[bit_index-DISTANCE];
            end
            else begin : PASS_THROUGH
                assign generate_out[bit_index]  = generate_in[bit_index];
                assign propagate_out[bit_index] = propagate_in[bit_index];
            end
        end
    endgenerate
endmodule
