// Full adder.
// Advantage: handles a carry-in and is the basic building block of adders.
// Disadvantage: a chain of full adders has carry propagation delay.
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
