`timescale 1ns/1ps
// Generated standalone smoke test for subtractor.
module tb_subtractor_smoke;
    reg a;
    reg b;
    reg bin;
    wire diff;
    wire bout;

    subtractor dut (
        .a(a),
        .b(b),
        .bin(bin),
        .diff(diff),
        .bout(bout)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        bin = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            bin = $random;
            #1;
            if ((^diff) === 1'bx) begin $display("FAIL: subtractor.diff is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^bout) === 1'bx) begin $display("FAIL: subtractor.bout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: subtractor reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_subtractor_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
