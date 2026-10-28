`timescale 1ns/1ps
// Generated standalone smoke test for pipelined_multiplier.
module tb_pipelined_multiplier_smoke;
    localparam integer WIDTH = 8;
    reg clk;
    reg rst_n;
    reg valid_i;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire valid_o;
    wire [2*WIDTH-1:0] product;

    pipelined_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .a(a),
        .b(b),
        .valid_o(valid_o),
        .product(product)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        valid_i = 0;
        a = 0;
        b = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            valid_i = $random;
            a = $random;
            b = $random;
            #1;
            if ((^valid_o) === 1'bx) begin $display("FAIL: pipelined_multiplier.valid_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^product) === 1'bx) begin $display("FAIL: pipelined_multiplier.product is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pipelined_multiplier reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pipelined_multiplier_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
