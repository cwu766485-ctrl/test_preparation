// Carry-select adder.
// Advantage: calculates both carry cases in parallel for lower delay.
// Disadvantage: duplicates adders, so area and power are higher.
module carry_select_adder #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);
    wire [WIDTH-1:0] sum0;
    wire [WIDTH-1:0] sum1;
    wire             cout0;
    wire             cout1;

    assign {cout0, sum0} = {1'b0, a} + {1'b0, b};
    assign {cout1, sum1} = {1'b0, a} + {1'b0, b} + {{WIDTH{1'b0}}, 1'b1};
    assign sum            = cin ? sum1 : sum0;
    assign cout           = cin ? cout1 : cout0;
endmodule
