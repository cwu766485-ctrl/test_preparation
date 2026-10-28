`timescale 1ns/1ps
// Generated standalone smoke test for popcount32.
module tb_popcount32_smoke;
    reg [31:0] data_i;
    wire [5:0] count;

    popcount32 dut (
        .data_i(data_i),
        .count(count)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        data_i = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            data_i = $random;
            #1;
            if ((^count) === 1'bx) begin $display("FAIL: popcount32.count is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: popcount32 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_popcount32_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
