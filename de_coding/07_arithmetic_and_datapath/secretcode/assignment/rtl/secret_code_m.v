// One independent modulo-8 digit generator. It has no secret-code input.
// carry_out is combinational so cascaded M blocks advance on the same edge.
module secret_code_m (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       clear,
    input  wire       enable,
    output reg  [2:0] value,
    output wire       carry_out
);
    assign carry_out = enable && (&value);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            value <= 3'b000;
        else if (clear)
            value <= 3'b000;
        else if (enable)
            value <= value + 3'b001;
    end
endmodule
