// Funnel shifter.
// Advantage: shifts across a concatenated double-width input.
// Disadvantage: requires two source words and wider routing.
// dir=1 selects the low half after a right shift; dir=0 selects the high half after a left shift.
module funnel_shifter #(
    parameter integer WIDTH = 8,
    parameter integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire [WIDTH-1:0] din_high,
    input  wire [WIDTH-1:0] din_low,
    input  wire [SHAMT_WIDTH-1:0] shamt,
    input  wire             dir,
    output wire [WIDTH-1:0] dout
);
    wire [2*WIDTH-1:0] combined;
    wire [2*WIDTH-1:0] shifted;
    assign combined = {din_high, din_low};
    assign shifted = dir ? (combined >> shamt) : (combined << shamt);
    assign dout    = dir ? shifted[WIDTH-1:0] : shifted[2*WIDTH-1:WIDTH];
endmodule
