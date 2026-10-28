`timescale 1ns/1ps
// Generated standalone smoke test for saturating_subtractor.
module tb_saturating_subtractor_smoke;
    localparam integer WIDTH = 8;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    wire [WIDTH-1:0] result;
    wire underflow;

    saturating_subtractor dut (
        .a(a),
        .b(b),
        .result(result),
        .underflow(underflow)
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
            if ((^result) === 1'bx) begin $display("FAIL: saturating_subtractor.result is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^underflow) === 1'bx) begin $display("FAIL: saturating_subtractor.underflow is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: saturating_subtractor reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_saturating_subtractor_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("saturating_subtractor_tb_saturating_subtractor_smoke.vcd");
        $dumpvars(0, tb_saturating_subtractor_smoke);
    end

endmodule
