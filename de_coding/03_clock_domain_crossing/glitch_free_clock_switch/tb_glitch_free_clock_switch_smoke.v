`timescale 1ns/1ps
// Generated standalone smoke test for glitch_free_clock_switch.
module tb_glitch_free_clock_switch_smoke;
    reg clk0;
    reg clk1;
    reg sel_async;
    reg rst_n;
    wire clk_out;

    glitch_free_clock_switch dut (
        .clk0(clk0),
        .clk1(clk1),
        .sel_async(sel_async),
        .rst_n(rst_n),
        .clk_out(clk_out)
    );
    always #5 clk0 = ~clk0;
    always #7 clk1 = ~clk1;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk0 = 1'b0;
        clk1 = 1'b0;
        sel_async = 0;
        rst_n = 1'b0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk0);
            sel_async = $random;
            #1;
            if ((^clk_out) === 1'bx) begin $display("FAIL: glitch_free_clock_switch.clk_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: glitch_free_clock_switch reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_glitch_free_clock_switch_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
