// Barrel shifter.
// Advantage: shifts by any amount in one combinational operation.
// Disadvantage: a large MUX network can consume area and affect timing.
// dir=1 shifts right; dir=0 shifts left.
module barrel_shifter #(
    parameter integer WIDTH = 8,
    parameter integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire [WIDTH-1:0] din,
    input  wire [SHAMT_WIDTH-1:0] shamt,
    input  wire             dir,
    output wire [WIDTH-1:0] dout
);
    assign dout = dir ? (din >> shamt) : (din << shamt);
endmodule
