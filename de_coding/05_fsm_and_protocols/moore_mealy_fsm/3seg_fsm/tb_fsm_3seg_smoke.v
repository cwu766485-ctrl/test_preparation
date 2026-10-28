`timescale 1ns/1ps
// Generated standalone smoke test for fsm_3seg.
module tb_fsm_3seg_smoke;
    reg clk;
    reg rst_n;
    reg start;
    wire [1:0] out;

    fsm_3seg dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .out(out)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            #1;
            if ((^out) === 1'bx) begin $display("FAIL: fsm_3seg.out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: fsm_3seg reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_fsm_3seg_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
