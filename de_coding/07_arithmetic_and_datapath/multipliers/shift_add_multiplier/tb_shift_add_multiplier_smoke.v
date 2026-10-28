`timescale 1ns/1ps
// Generated standalone smoke test for shift_add_multiplier.
module tb_shift_add_multiplier_smoke;
    localparam integer WIDTH = 8;
    reg clk;
    reg rst_n;
    reg start;
    reg [WIDTH-1:0] multiplicand;
    reg [WIDTH-1:0] multiplier;
    wire [2*WIDTH-1:0] product;
    wire busy;
    wire done;

    shift_add_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .busy(busy),
        .done(done)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        multiplicand = 0;
        multiplier = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            multiplicand = $random;
            multiplier = $random;
            #1;
            if ((^product) === 1'bx) begin $display("FAIL: shift_add_multiplier.product is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^busy) === 1'bx) begin $display("FAIL: shift_add_multiplier.busy is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: shift_add_multiplier.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: shift_add_multiplier reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_shift_add_multiplier_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("shift_add_multiplier_tb_shift_add_multiplier_smoke.vcd");
        $dumpvars(0, tb_shift_add_multiplier_smoke);
    end

endmodule
