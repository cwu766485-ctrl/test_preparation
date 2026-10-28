`timescale 1ns/1ps
module tb_matvec_2x2;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0;
    reg signed [7:0] m00=0, m01=0, m10=0, m11=0, x0=0, x1=0;
    wire signed [16:0] y0, y1;
    wire busy, done;
    integer i;
    matvec_2x2 dut (clk, rst_n, start, m00, m01, m10, m11, x0, x1, y0, y1, busy, done);
    always #5 clk = ~clk;

    initial begin
        #12 rst_n = 1'b1;
        @(negedge clk);
        m00=2; m01=3; m10=-1; m11=4; x0=5; x1=-2; start=1;
        @(posedge clk); #1; start=0;
        for (i=0; i<4; i=i+1) begin @(posedge clk); #1; end
        if (done !== 1'b1 || y0 !== 17'sd4 || y1 !== -17'sd13) begin
            $display("FAIL: y0=%0d y1=%0d done=%b expected=(4,-13)", y0, y1, done);
            $finish;
        end
        $display("PASS: signed 2x2 matrix-vector product");
        $finish;
    end
endmodule
