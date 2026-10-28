// Rotate shifter.
// Advantage: preserves every bit by wrapping shifted bits around.
// Disadvantage: requires extra wraparound logic and special handling for zero.
// dir=1 rotates right; dir=0 rotates left. Amounts are normalized modulo WIDTH.
module rotate_shifter #(
    parameter integer WIDTH = 8,
    parameter integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire [WIDTH-1:0] din,
    input  wire [SHAMT_WIDTH-1:0] shamt,
    input  wire             dir,
    output reg  [WIDTH-1:0] dout
);
    localparam integer AMOUNT_WIDTH = SHAMT_WIDTH + 1;
    localparam [AMOUNT_WIDTH-1:0] WIDTH_VALUE = WIDTH[AMOUNT_WIDTH-1:0];
    wire [AMOUNT_WIDTH-1:0] shamt_extended = {{(AMOUNT_WIDTH-SHAMT_WIDTH){1'b0}}, shamt};
    wire [AMOUNT_WIDTH-1:0] normalized_shamt = shamt_extended % WIDTH_VALUE;
    wire [AMOUNT_WIDTH-1:0] opposite_shamt = WIDTH_VALUE - normalized_shamt;

    always @(*) begin
        if (normalized_shamt == 0) begin
            dout = din;
        end
        else if (dir) begin
            dout = (din >> normalized_shamt) | (din << opposite_shamt);
        end
        else begin
            dout = (din << normalized_shamt) | (din >> opposite_shamt);
        end
    end
endmodule
