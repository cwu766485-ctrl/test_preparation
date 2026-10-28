`timescale 1ns/1ps
// Generated standalone smoke test for pipelined_divider.
module tb_pipelined_divider_smoke;
    localparam integer WIDTH = 8;
    reg clk;
    reg rst_n;
    reg valid_i;
    reg [WIDTH-1:0] dividend;
    reg [WIDTH-1:0] divisor;
    wire valid_o;
    wire [WIDTH-1:0] quotient;
    wire [WIDTH-1:0] remainder;
    wire div_zero;

    pipelined_divider dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .dividend(dividend),
        .divisor(divisor),
        .valid_o(valid_o),
        .quotient(quotient),
        .remainder(remainder),
        .div_zero(div_zero)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        valid_i = 0;
        dividend = 0;
        divisor = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            valid_i = $random;
            dividend = $random;
            divisor = $random;
            #1;
            if ((^valid_o) === 1'bx) begin $display("FAIL: pipelined_divider.valid_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^quotient) === 1'bx) begin $display("FAIL: pipelined_divider.quotient is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^remainder) === 1'bx) begin $display("FAIL: pipelined_divider.remainder is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^div_zero) === 1'bx) begin $display("FAIL: pipelined_divider.div_zero is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pipelined_divider reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pipelined_divider_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("pipelined_divider_tb_pipelined_divider_smoke.vcd");
        $dumpvars(0, tb_pipelined_divider_smoke);
    end

endmodule
