`timescale 1ns/1ps
module tb_dot_product3;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0;
    reg signed [7:0] a = 0, b = 0;
    wire signed [17:0] result;
    wire busy, done;
    dot_product3 dut (clk, rst_n, start, a, b, result, busy, done);
    always #5 clk = ~clk;

    initial begin
        #12 rst_n = 1'b1;
        @(negedge clk); start = 1'b1; a = 8'sd2; b = 8'sd3;
        @(posedge clk); #1;
        @(negedge clk); start = 1'b0; a = -8'sd4; b = 8'sd5;
        @(posedge clk); #1;
        @(negedge clk); a = 8'sd7; b = -8'sd2;
        @(posedge clk); #1;
        if (done !== 1'b1 || result !== -18'sd28) begin
            $display("FAIL: dot product result=%0d done=%b expected=-28", result, done);
            $finish;
        end
        $display("PASS: signed three-term dot product");
        $finish;
    end
endmodule
