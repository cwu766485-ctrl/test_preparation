`timescale 1ns/1ps
// Generated standalone smoke test for half_adder.
module tb_half_adder_smoke;
    reg a;
    reg b;
    wire sum;
    wire carry;

    half_adder dut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
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
            if ((^sum) === 1'bx) begin $display("FAIL: half_adder.sum is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^carry) === 1'bx) begin $display("FAIL: half_adder.carry is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: half_adder reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_half_adder_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
