// One-bit full adder, used as the M3 datapath building block.
module full_adder (
    input wire a, input wire b, input wire cin,
    output wire sum, output wire cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule
