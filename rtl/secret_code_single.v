`timescale 1ns/1ps
// Alternative #8: a single 12-bit generator/comparator.
// The counter has no secret-code input; comparison is external to it.
module secret_code_single (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        activate,
    input  wire [11:0] secret_code,
    output reg  [11:0] candidate,
    output wire [3:0]  match_bits,
    output reg         busy,
    output reg         relay_open
);
    wire all_match;
    assign match_bits[3] = (candidate[11:9] == secret_code[11:9]);
    assign match_bits[2] = (candidate[8:6]   == secret_code[8:6]);
    assign match_bits[1] = (candidate[5:3]   == secret_code[5:3]);
    assign match_bits[0] = (candidate[2:0]   == secret_code[2:0]);
    assign all_match = &match_bits;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            candidate  <= 12'd0;
            busy       <= 1'b0;
            relay_open <= 1'b0;
        end else if (activate) begin
            candidate  <= 12'd0;
            busy       <= 1'b1;
            relay_open <= 1'b0;
        end else if (busy) begin
            if (all_match) begin
                busy       <= 1'b0;
                relay_open <= 1'b1;
            end else begin
                candidate <= candidate + 12'd1;
            end
        end
    end
endmodule
