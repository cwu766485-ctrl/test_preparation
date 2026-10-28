// Half adder.
// Advantage: minimum area and one-level combinational logic.
// Disadvantage: cannot accept a carry-in; only suitable for the least bit.
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
