// Simple unsigned ALU. For subtraction, carry_out is 1 when no borrow occurred.
// Advantage: demonstrates shared add/sub/logic datapath control.
// Disadvantage: a single combinational block may become a timing bottleneck.
module simple_alu #(
    parameter integer WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,
    output reg  [WIDTH-1:0] result,
    output reg              carry_out,
    output wire             zero
);
    always @(*) begin
        result    = 0;
        carry_out = 1'b0;

        case (op)
            3'b000: {carry_out, result} = {1'b0, a} + {1'b0, b};
            // For subtraction, carry_out is 1 when no borrow occurred.
            3'b001: {carry_out, result} = {1'b0, a} + {1'b0, ~b} + {{WIDTH{1'b0}}, 1'b1};
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = a << b;
            3'b110: result = a >> b;
            default: result = 0;
        endcase
    end

    assign zero = (result == 0);
endmodule
