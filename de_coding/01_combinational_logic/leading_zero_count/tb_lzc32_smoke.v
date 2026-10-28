`timescale 1ns/1ps
// Generated standalone smoke test for lzc32.
module tb_lzc32_smoke;
    reg [31:0] din;
    wire [5:0] count;

    lzc32 dut (
        .din(din),
        .count(count)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        din = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            din = $random;
            #1;
            if ((^count) === 1'bx) begin $display("FAIL: lzc32.count is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: lzc32 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_lzc32_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("leading_zero_count_tb_lzc32_smoke.vcd");
        $dumpvars(0, tb_lzc32_smoke);
    end

endmodule
