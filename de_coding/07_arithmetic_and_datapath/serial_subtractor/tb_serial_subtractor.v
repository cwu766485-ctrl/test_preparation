`timescale 1ns/1ps
module tb_serial_subtractor;
    reg clk=1'b0, rst_n=1'b0, start=1'b0;
    reg [7:0] a=0, b=0;
    wire [7:0] difference;
    wire borrow_out, busy, done;
    serial_subtractor #(.WIDTH(8)) dut (clk, rst_n, start, a, b, difference, borrow_out, busy, done);
    always #5 clk=~clk;

    task run_sub;
        input [7:0] x, y, expected;
        input expected_borrow;
        integer i;
        begin
            @(negedge clk); a=x; b=y; start=1'b1;
            @(posedge clk); #1; start=1'b0;
            for (i=0; i<8; i=i+1) begin @(posedge clk); #1; end
            if (done!==1'b1 || difference!==expected || borrow_out!==expected_borrow) begin
                $display("FAIL: %0d-%0d difference=%0d borrow=%b", x, y, difference, borrow_out);
                $finish;
            end
        end
    endtask

    initial begin
        #12 rst_n=1'b1;
        run_sub(8'd31, 8'd9, 8'd22, 1'b0);
        run_sub(8'd0, 8'd1, 8'd255, 1'b1);
        $display("PASS: variable-width serial subtractor");
        $finish;
    end
endmodule
