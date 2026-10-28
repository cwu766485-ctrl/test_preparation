`timescale 1ns/1ps
// Generated standalone smoke test for comparator.
module tb_comparator_smoke;
    localparam integer W = 8;
    reg [W-1:0] a;
    reg [W-1:0] b;
    wire gt;
    wire eq;
    wire lt;

    comparator dut (
        .a(a),
        .b(b),
        .gt(gt),
        .eq(eq),
        .lt(lt)
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
            if ((^gt) === 1'bx) begin $display("FAIL: comparator.gt is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^eq) === 1'bx) begin $display("FAIL: comparator.eq is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^lt) === 1'bx) begin $display("FAIL: comparator.lt is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: comparator reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_comparator_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("comparator_tb_comparator_smoke.vcd");
        $dumpvars(0, tb_comparator_smoke);
    end

endmodule
