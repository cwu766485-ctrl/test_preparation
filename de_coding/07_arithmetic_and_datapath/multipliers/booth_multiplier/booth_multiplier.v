// Combinational signed radix-2 Booth multiplier.
// Advantage: recodes adjacent multiplier bits into 0, +A, or -A partial products.
// Disadvantage: recoding and the signed partial-product adder chain add control complexity.
module booth_multiplier #(
    parameter integer WIDTH = 8
) (
    input  wire signed [WIDTH-1:0] a,
    input  wire signed [WIDTH-1:0] b,
    output wire signed [2*WIDTH-1:0] product
);
    reg [WIDTH:0] booth_pair_vector;
    reg signed [2*WIDTH-1:0] multiplicand_extended;
    reg signed [2*WIDTH-1:0] shifted_multiplicand;
    reg signed [2*WIDTH-1:0] booth_sum;
    integer bit_index;

    always @* begin
        booth_pair_vector     = {b, 1'b0};
        multiplicand_extended = {{WIDTH{a[WIDTH-1]}}, a};
        shifted_multiplicand  = {2*WIDTH{1'b0}};
        booth_sum             = {2*WIDTH{1'b0}};

        for (bit_index = 0; bit_index < WIDTH; bit_index = bit_index + 1) begin
            shifted_multiplicand = multiplicand_extended <<< bit_index;
            case ({booth_pair_vector[bit_index+1], booth_pair_vector[bit_index]})
                2'b01: booth_sum = booth_sum + shifted_multiplicand;
                2'b10: booth_sum = booth_sum - shifted_multiplicand;
                default: booth_sum = booth_sum;
            endcase
        end
    end

    assign product = booth_sum;
endmodule
