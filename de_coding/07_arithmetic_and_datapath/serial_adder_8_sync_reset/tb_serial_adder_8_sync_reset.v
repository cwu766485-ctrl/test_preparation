`timescale 1ns/1ps
module tb_serial_adder_8_sync_reset;
    reg clk=1'b0, rst=1'b1, start=1'b0;
    reg [7:0] a=0, b=0;
    wire [8:0] sum;
    wire busy, done;
    integer i;
    serial_adder_8_sync_reset dut (clk, rst, start, a, b, sum, busy, done);
    always #5 clk=~clk;

    initial begin
        @(posedge clk); #1; rst=1'b0;
        @(negedge clk); start=1'b1; a=8'd100; b=8'd200;
        @(posedge clk); #1; start=1'b0;
        repeat (3) begin @(posedge clk); #1; end
        @(negedge clk); rst=1'b1;
        #1;
        if (busy !== 1'b1) begin $display("FAIL: synchronous reset changed state before clock"); $finish; end
        @(posedge clk); #1;
        if (busy !== 1'b0 || sum !== 9'd0) begin $display("FAIL: synchronous reset did not clear at clock"); $finish; end
        @(negedge clk); rst=1'b0; start=1'b1; a=8'd200; b=8'd100;
        @(posedge clk); #1; start=1'b0;
        for (i=0; i<8; i=i+1) begin @(posedge clk); #1; end
        if (done !== 1'b1 || sum !== 9'd300) begin
            $display("FAIL: sum=%0d done=%b expected=300", sum, done);
            $finish;
        end
        $display("PASS: eight-bit serial adder with synchronous reset");
        $finish;
    end
    initial begin
        $dumpfile("serial_adder_8_sync_reset_tb_serial_adder_8_sync_reset.vcd");
        $dumpvars(0, tb_serial_adder_8_sync_reset);
    end

endmodule
