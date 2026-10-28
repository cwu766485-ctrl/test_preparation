// One-stage registered ALU.
// Advantage: registers isolate combinational delay and align valid timing.
// Disadvantage: adds one-cycle latency and consumes clocked storage.
module pipelined_alu #(
    parameter integer WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             valid_i,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,
    output reg              valid_o,
    output reg  [WIDTH-1:0] result,
    output reg              zero
);
    reg [WIDTH-1:0] alu_result;

    always @* begin
        alu_result = {WIDTH{1'b0}};
        case (op)
            3'b000: alu_result = a + b;
            3'b001: alu_result = a - b;
            3'b010: alu_result = a & b;
            3'b011: alu_result = a | b;
            3'b100: alu_result = a ^ b;
            3'b101: alu_result = a << b;
            3'b110: alu_result = a >> b;
            default: alu_result = {WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_o <= 1'b0;
            result  <= 0;
            zero    <= 1'b0;
        end
        else begin
            valid_o <= valid_i;
            if (valid_i) begin
                result <= alu_result;
                zero   <= (alu_result == {WIDTH{1'b0}});
            end
        end
    end
endmodule
