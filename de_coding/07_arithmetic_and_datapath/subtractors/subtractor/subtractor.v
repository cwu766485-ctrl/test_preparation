// Subtractor with borrow-in.
// Advantage: direct multi-bit subtraction primitive.
// Disadvantage: borrow propagation can limit timing in a long chain.
module subtractor (
    input  wire a,
    input  wire b,
    input  wire bin,
    output wire diff,
    output wire bout
);
    assign diff = a ^ b ^ bin;
    assign bout = (~a & b) | (~a & bin) | (b & bin);
endmodule
