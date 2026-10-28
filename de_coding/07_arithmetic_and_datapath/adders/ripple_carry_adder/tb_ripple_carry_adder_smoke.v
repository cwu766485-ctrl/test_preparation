`timescale 1ns/1ps
// Generated standalone smoke test for ripple_carry_adder.
module tb_ripple_carry_adder_smoke;
    localparam integer WIDTH = 8;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg cin;
    wire [WIDTH-1:0] sum;
    wire cout;

    ripple_carry_adder dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        cin = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            cin = $random;
            #1;
            if ((^sum) === 1'bx) begin $display("FAIL: ripple_carry_adder.sum is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^cout) === 1'bx) begin $display("FAIL: ripple_carry_adder.cout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: ripple_carry_adder reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_ripple_carry_adder_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
