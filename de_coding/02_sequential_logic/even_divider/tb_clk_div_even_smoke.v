`timescale 1ns/1ps
// Generated standalone smoke test for clk_div_even.
module tb_clk_div_even_smoke;
    localparam integer N = 10;
    reg clk;
    reg rst_n;
    wire clk_div;

    clk_div_even dut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_div(clk_div)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            #1;
            if ((^clk_div) === 1'bx) begin $display("FAIL: clk_div_even.clk_div is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: clk_div_even reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_clk_div_even_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
