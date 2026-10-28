// Unified unsigned adder/subtractor. During subtraction, carry_out indicates no borrow.
// Advantage: reuses one adder for both operations and suits an ALU.
// Disadvantage: the control inversion path adds a small amount of delay.
module add_sub_unit #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             sub,
    output wire [WIDTH-1:0] result,
    output wire             carry_out
);
    assign {carry_out, result} =
        {1'b0, a} + {1'b0, (b ^ {WIDTH{sub}})} + {{WIDTH{1'b0}}, sub};
endmodule
