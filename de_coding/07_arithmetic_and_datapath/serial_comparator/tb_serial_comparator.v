`timescale 1ns/1ps
module tb_serial_comparator;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0;
    reg [7:0] a = 0, b = 0;
    wire greater, equal, less, busy, done;
    integer n;
    serial_comparator #(.WIDTH(8)) dut (clk, rst_n, start, a, b, greater, equal, less, busy, done);
    always #5 clk = ~clk;

    task compare_values;
        input [7:0] x, y;
        input expected_greater, expected_equal, expected_less;
        integer timeout;
        begin
            @(negedge clk); a = x; b = y; start = 1'b1;
            @(posedge clk); #1; start = 1'b0;
            timeout = 0;
            while (done !== 1'b1 && timeout < 8) begin
                @(posedge clk); #1; timeout = timeout + 1;
            end
            if (done !== 1'b1 || {greater,equal,less} !== {expected_greater,expected_equal,expected_less}) begin
                $display("FAIL: compare %0d and %0d got %b%b%b", x, y, greater, equal, less);
                $finish;
            end
        end
    endtask

    initial begin
        #12 rst_n = 1'b1;
        compare_values(8'd200, 8'd17, 1'b1, 1'b0, 1'b0);
        compare_values(8'd4, 8'd201, 1'b0, 1'b0, 1'b1);
        compare_values(8'd55, 8'd55, 1'b0, 1'b1, 1'b0);
        $display("PASS: unsigned bit-serial comparator");
        $finish;
    end
endmodule
