// Logical left/right shifter.
// Advantage: simple combinational implementation for unsigned data.
// Disadvantage: right shift always inserts zeros and cannot preserve sign.
// dir=1 shifts right; dir=0 shifts left.
module logical_shifter #(
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
