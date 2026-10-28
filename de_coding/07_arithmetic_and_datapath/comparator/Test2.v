module Comparator (
    input  wire [2:0] A,
    input  wire [2:0] B,
    output wire       EQ
);
    assign EQ = (A == B);

endmodule


module Test2 (
    input  wire [2:0] A1, A2, A3, A4,
    output wire       open        // no trailing comma
);
    // Secret code is internal, not visible to the generator
    localparam [2:0] v1 = 3'd0;
    localparam [2:0] v2 = 3'd1;
    localparam [2:0] v3 = 3'd0;
    localparam [2:0] v4 = 3'd7;

    wire [3:0] o;

    Comparator M1 (.A(A1), .B(v1), .EQ(o[0]));
    Comparator M2 (.A(A2), .B(v2), .EQ(o[1]));
    Comparator M3 (.A(A3), .B(v3), .EQ(o[2]));
    Comparator M4 (.A(A4), .B(v4), .EQ(o[3]));

    assign open = &o;
endmodule
