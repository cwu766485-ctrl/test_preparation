`timescale 1ns/1ps
// Generated standalone smoke test for sin_lut.
module tb_sin_lut_smoke;
    reg [7:0] addr;
    wire signed [7:0] sin_out;

    sin_lut dut (
        .addr(addr),
        .sin_out(sin_out)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        addr = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            addr = $random;
            #1;
            if ((^sin_out) === 1'bx) begin $display("FAIL: sin_lut.sin_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: sin_lut reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_sin_lut_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
