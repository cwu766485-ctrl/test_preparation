`timescale 1ns/1ps
// Generated standalone smoke test for seq_detect_101.
module tb_seq_detect_101_smoke;
    reg clk;
    reg rst_n;
    reg data;
    wire flag;

    seq_detect_101 dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(data),
        .flag(flag)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        data = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            data = $random;
            #1;
            if ((^flag) === 1'bx) begin $display("FAIL: seq_detect_101.flag is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: seq_detect_101 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_seq_detect_101_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
