`timescale 1ns/1ps
// Generated standalone smoke test for debounce.
module tb_debounce_smoke;
    localparam integer CNT_MAX = 1_000_000;
    reg clk;
    reg rst_n;
    reg btn_in;
    wire btn_out;

    debounce dut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        btn_in = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            btn_in = $random;
            #1;
            if ((^btn_out) === 1'bx) begin $display("FAIL: debounce.btn_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: debounce reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_debounce_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
