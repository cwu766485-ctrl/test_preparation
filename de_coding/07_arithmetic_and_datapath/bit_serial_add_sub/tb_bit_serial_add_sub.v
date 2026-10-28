`timescale 1ns/1ps
module tb_bit_serial_add_sub;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0, sub = 1'b0;
    reg [7:0] a = 0, b = 0;
    wire [7:0] result;
    wire carry_out, busy, done;
    integer i;
    bit_serial_add_sub #(.WIDTH(8)) dut (clk, rst_n, start, sub, a, b, result, carry_out, busy, done);
    always #5 clk = ~clk;

    task run_op;
        input mode;
        input [7:0] x, y, expected;
        input expected_carry;
        integer n;
        begin
            @(negedge clk); sub = mode; a = x; b = y; start = 1'b1;
            @(posedge clk); #1; start = 1'b0;
            for (n = 0; n < 8; n = n + 1) begin @(posedge clk); #1; end
            if (done !== 1'b1 || result !== expected || carry_out !== expected_carry) begin
                $display("FAIL: mode=%b a=%0d b=%0d result=%0d carry=%b", mode, x, y, result, carry_out);
                $finish;
            end
        end
    endtask

    initial begin
        #12 rst_n = 1'b1;
        run_op(1'b0, 8'd200, 8'd100, 8'd44, 1'b1);
        run_op(1'b1, 8'd7, 8'd10, 8'd253, 1'b0);
        $display("PASS: bit-serial add/subtract");
        $finish;
    end
    initial begin
        $dumpfile("bit_serial_add_sub_tb_bit_serial_add_sub.vcd");
        $dumpvars(0, tb_bit_serial_add_sub);
    end

endmodule
