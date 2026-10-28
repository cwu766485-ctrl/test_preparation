`timescale 1ns/1ps
// Generated standalone smoke test for mux2_assign.
module tb_mux2_assign_smoke;
    reg a;
    reg b;
    reg sel;
    wire y;

    mux2_assign dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        sel = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            sel = $random;
            #1;
            if ((^y) === 1'bx) begin $display("FAIL: mux2_assign.y is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: mux2_assign reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_mux2_assign_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
