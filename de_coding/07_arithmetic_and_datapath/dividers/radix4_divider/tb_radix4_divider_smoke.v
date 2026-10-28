`timescale 1ns/1ps
// Generated standalone smoke test for radix4_divider.
module tb_radix4_divider_smoke;
    localparam integer WIDTH = 8;
    reg clk;
    reg rst_n;
    reg start;
    reg [WIDTH-1:0] dividend;
    reg [WIDTH-1:0] divisor;
    wire [WIDTH-1:0] quotient;
    wire [WIDTH-1:0] remainder;
    wire done;
    wire div_zero;

    radix4_divider dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder),
        .done(done),
        .div_zero(div_zero)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        dividend = 0;
        divisor = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            dividend = $random;
            divisor = $random;
            #1;
            if ((^quotient) === 1'bx) begin $display("FAIL: radix4_divider.quotient is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^remainder) === 1'bx) begin $display("FAIL: radix4_divider.remainder is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: radix4_divider.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^div_zero) === 1'bx) begin $display("FAIL: radix4_divider.div_zero is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: radix4_divider reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_radix4_divider_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("radix4_divider_tb_radix4_divider_smoke.vcd");
        $dumpvars(0, tb_radix4_divider_smoke);
    end

endmodule
