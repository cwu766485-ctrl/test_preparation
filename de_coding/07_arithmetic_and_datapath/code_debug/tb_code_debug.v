`timescale 1ns/1ps
module tb_code_debug;
    reg clk = 1'b0, rst_n = 1'b0, serial_in = 1'b0;
    wire [3:0] fixed_q, buggy_q;
    reg [3:0] expected_q = 4'b0000;
    integer i;
    reg bug_seen = 1'b0;

    code_debug_shift_reg fixed_dut (clk, rst_n, serial_in, fixed_q);
    buggy_shift_reg buggy_dut (clk, rst_n, serial_in, buggy_q);
    always #5 clk = ~clk;

    initial begin
        #12 rst_n = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            serial_in = (i == 0);
            expected_q = {expected_q[2:0], serial_in};
            @(posedge clk); #1;
            if (fixed_q !== expected_q) begin
                $display("FAIL: corrected shift register q=%b expected=%b", fixed_q, expected_q);
                $finish;
            end
            if (buggy_q !== expected_q) bug_seen = 1'b1;
        end
        if (!bug_seen) $display("FAIL: test did not expose the blocking-assignment bug");
        else $display("PASS: corrected RTL works and the intentional bug was detected");
        $finish;
    end
    initial begin
        $dumpfile("code_debug_tb_code_debug.vcd");
        $dumpvars(0, tb_code_debug);
    end

endmodule
