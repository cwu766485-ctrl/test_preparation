`timescale 1ns/1ps
// Generated standalone smoke test for dff_async.
module tb_dff_async_smoke;
    reg clk;
    reg rst_n;
    reg d;
    wire q;

    dff_async dut (
        .clk(clk),
        .rst_n(rst_n),
        .d(d),
        .q(q)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        d = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            d = $random;
            #1;
            if ((^q) === 1'bx) begin $display("FAIL: dff_async.q is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: dff_async reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_dff_async_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
