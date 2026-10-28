`timescale 1ns/1ps
// Generated standalone smoke test for booth_multiplier.
module tb_booth_multiplier_smoke;
    localparam integer WIDTH = 8;
    reg signed [WIDTH-1:0] a;
    reg signed [WIDTH-1:0] b;
    wire signed [2*WIDTH-1:0] product;

    booth_multiplier dut (
        .a(a),
        .b(b),
        .product(product)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            #1;
            if ((^product) === 1'bx) begin $display("FAIL: booth_multiplier.product is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: booth_multiplier reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_booth_multiplier_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("booth_multiplier_tb_booth_multiplier_smoke.vcd");
        $dumpvars(0, tb_booth_multiplier_smoke);
    end

endmodule
