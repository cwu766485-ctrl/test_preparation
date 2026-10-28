`timescale 1ns/1ps
module tb_serial_adder;
    reg clk=1'b0, rst_n=1'b0, start=1'b0;
    reg [15:0] a=0, b=0;
    wire [16:0] sum;
    wire busy, done;
    integer i;
    modular_serial_adder #(.WIDTH(16)) dut (clk, rst_n, start, a, b, sum, busy, done);
    always #5 clk=~clk;

    task run_add;
        input [15:0] x, y;
        input [16:0] expected;
        integer n;
        begin
            @(negedge clk); a=x; b=y; start=1'b1;
            @(posedge clk); #1; start=1'b0;
            for (n=0; n<16; n=n+1) begin @(posedge clk); #1; end
            if (done!==1'b1 || sum!==expected) begin
                $display("FAIL: %0d+%0d got %0d expected %0d", x, y, sum, expected);
                $finish;
            end
        end
    endtask

    initial begin
        #12 rst_n=1'b1;
        run_add(16'hABCD, 16'h1234, 17'h0BE01);
        run_add(16'hFFFF, 16'h0001, 17'h10000);
        $display("PASS: modular 16-bit serial adder hierarchy");
        $finish;
    end
endmodule
