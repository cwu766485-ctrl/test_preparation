`timescale 1ns/1ps
module tb_sum_average;
    reg clk=1'b0, rst_n=1'b0, start=1'b0, valid=1'b0;
    reg [7:0] data_in=0;
    wire [9:0] sum;
    wire [7:0] average;
    wire busy, done;
    integer i;
    reg [7:0] samples [0:3];
    sum_average #(.WIDTH(8), .COUNT(4)) dut (clk, rst_n, start, valid, data_in, sum, average, busy, done);
    always #5 clk = ~clk;

    initial begin
        samples[0]=10; samples[1]=20; samples[2]=30; samples[3]=40;
        #12 rst_n=1'b1;
        @(negedge clk); start=1'b1;
        @(posedge clk); #1; start=1'b0;
        for (i=0; i<4; i=i+1) begin
            @(negedge clk); valid=1'b1; data_in=samples[i];
            @(posedge clk); #1;
        end
        valid=1'b0;
        if (done !== 1'b1 || sum !== 10'd100 || average !== 8'd25) begin
            $display("FAIL: sum=%0d average=%0d done=%b", sum, average, done);
            $finish;
        end
        $display("PASS: streaming sum and integer average");
        $finish;
    end
    initial begin
        $dumpfile("sum_average_tb_sum_average.vcd");
        $dumpvars(0, tb_sum_average);
    end

endmodule
