module mux2_gate(
    input  wire a,
    input  wire b,
    input  wire sel,
    output wire y
);

assign y = (~sel & a) | (sel & b);

endmodule