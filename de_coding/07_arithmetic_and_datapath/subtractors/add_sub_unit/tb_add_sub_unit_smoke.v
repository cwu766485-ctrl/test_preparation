`timescale 1ns/1ps
// Generated standalone smoke test for add_sub_unit.
module tb_add_sub_unit_smoke;
    localparam integer WIDTH = 8;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg sub;
    wire [WIDTH-1:0] result;
    wire carry_out;

    add_sub_unit dut (
        .a(a),
        .b(b),
        .sub(sub),
        .result(result),
        .carry_out(carry_out)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        sub = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            sub = $random;
            #1;
            if ((^result) === 1'bx) begin $display("FAIL: add_sub_unit.result is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^carry_out) === 1'bx) begin $display("FAIL: add_sub_unit.carry_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: add_sub_unit reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_add_sub_unit_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
