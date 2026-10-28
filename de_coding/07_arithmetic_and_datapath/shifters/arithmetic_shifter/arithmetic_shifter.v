// Arithmetic right shifter.
// Advantage: preserves the sign bit for signed two's-complement data.
// Disadvantage: it is intended for signed right shifts, not unsigned data.
module arithmetic_shifter #(
    parameter integer WIDTH = 8,
    parameter integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire signed [WIDTH-1:0] din,
    input  wire [SHAMT_WIDTH-1:0] shamt,
    output wire signed [WIDTH-1:0] dout
);
    assign dout = din >>> shamt;
endmodule
