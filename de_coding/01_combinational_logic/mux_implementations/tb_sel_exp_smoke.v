`timescale 1ns/1ps
// Generated standalone smoke test for sel_exp.
module tb_sel_exp_smoke;
    reg A;
    reg B;
    reg C;
    wire L;

    sel_exp dut (
        .A(A),
        .B(B),
        .C(C),
        .L(L)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        A = 0;
        B = 0;
        C = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            A = $random;
            B = $random;
            C = $random;
            #1;
            if ((^L) === 1'bx) begin $display("FAIL: sel_exp.L is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: sel_exp reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_sel_exp_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
