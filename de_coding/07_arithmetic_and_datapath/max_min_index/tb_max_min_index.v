`timescale 1ns/1ps
module tb_max_min_index;
    reg clk=1'b0, rst_n=1'b0, start=1'b0, valid=1'b0;
    reg [7:0] data_in=0;
    wire [7:0] min_value, max_value;
    wire [2:0] min_index, max_index;
    wire busy, done;
    integer i;
    reg [7:0] samples [0:4];
    max_min_index #(.WIDTH(8), .COUNT(5)) dut
      (clk, rst_n, start, valid, data_in, min_value, max_value, min_index, max_index, busy, done);
    always #5 clk = ~clk;

    initial begin
        samples[0]=8'd9; samples[1]=8'd3; samples[2]=8'd15; samples[3]=8'd3; samples[4]=8'd7;
        #12 rst_n=1'b1;
        @(negedge clk); start=1'b1;
        @(posedge clk); #1; start=1'b0;
        for (i=0; i<5; i=i+1) begin
            @(negedge clk); valid=1'b1; data_in=samples[i];
            @(posedge clk); #1;
        end
        valid=1'b0;
        if (done !== 1'b1 || min_value !== 8'd3 || min_index !== 3'd1 ||
            max_value !== 8'd15 || max_index !== 3'd2) begin
            $display("FAIL: min=%0d@%0d max=%0d@%0d done=%b", min_value, min_index, max_value, max_index, done);
            $finish;
        end
        $display("PASS: min/max values and first positions");
        $finish;
    end
    initial begin
        $dumpfile("max_min_index_tb_max_min_index.vcd");
        $dumpvars(0, tb_max_min_index);
    end

endmodule
