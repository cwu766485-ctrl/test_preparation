// Unsigned saturating subtractor.
// Advantage: avoids wraparound when a smaller value is subtracted from zero.
// Disadvantage: requires an additional comparison and is unsigned here.
module saturating_subtractor #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] result,
    output wire             underflow
);
    assign underflow = (a < b);
    assign result    = underflow ? {WIDTH{1'b0}} : a - b;
endmodule
