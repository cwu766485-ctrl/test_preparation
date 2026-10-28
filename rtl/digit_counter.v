`timescale 1ns/1ps
// M_i: no secret-code input; produces one 3-bit base-8 digit.
module digit_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       clear,
    input  wire       enable,
    output reg  [2:0] digit
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            digit <= 3'd0;
        else if (clear)
            digit <= 3'd0;
        else if (enable)
            digit <= digit + 3'd1;
    end
endmodule
