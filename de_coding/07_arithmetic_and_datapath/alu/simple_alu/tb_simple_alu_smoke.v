`timescale 1ns/1ps
// Generated standalone smoke test for simple_alu.
module tb_simple_alu_smoke;
    localparam integer WIDTH = 8;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [2:0] op;
    wire [WIDTH-1:0] result;
    wire carry_out;
    wire zero;

    simple_alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .carry_out(carry_out),
        .zero(zero)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        op = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            op = $random;
            #1;
            if ((^result) === 1'bx) begin $display("FAIL: simple_alu.result is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^carry_out) === 1'bx) begin $display("FAIL: simple_alu.carry_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^zero) === 1'bx) begin $display("FAIL: simple_alu.zero is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: simple_alu reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_simple_alu_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
