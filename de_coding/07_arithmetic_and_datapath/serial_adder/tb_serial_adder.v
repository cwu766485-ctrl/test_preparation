`timescale 1ns/1ps
module tb_serial_adder;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0;
    reg [7:0] a = 0, b = 0;
    wire [8:0] sum;
    wire busy, done;
    integer i;
    serial_adder #(.WIDTH(8)) dut (clk, rst_n, start, a, b, sum, busy, done);
    always #5 clk = ~clk;

    task run_add;
        input [7:0] x, y;
        input [8:0] expected;
        integer n;
        begin
            @(negedge clk); a = x; b = y; start = 1'b1;
            @(posedge clk); #1; start = 1'b0;
            for (n = 0; n < 8; n = n + 1) begin @(posedge clk); #1; end
            if (done !== 1'b1 || sum !== expected) begin
                $display("FAIL: %0d + %0d = %0d expected %0d done=%b", x, y, sum, expected, done);
                $finish;
            end
        end
    endtask

    initial begin
        #12 rst_n = 1'b1;
        run_add(8'd13, 8'd7, 9'd20);
        run_add(8'd255, 8'd1, 9'd256);
        $display("PASS: variable-width serial adder");
        $finish;
    end
endmodule
