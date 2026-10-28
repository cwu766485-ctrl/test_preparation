`timescale 1ns/1ps
// Generated standalone smoke test for parity_gen.
module tb_parity_gen_smoke;
    reg [7:0] data;
    wire even_p;
    wire odd_p;

    parity_gen dut (
        .data(data),
        .even_p(even_p),
        .odd_p(odd_p)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        data = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            data = $random;
            #1;
            if ((^even_p) === 1'bx) begin $display("FAIL: parity_gen.even_p is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^odd_p) === 1'bx) begin $display("FAIL: parity_gen.odd_p is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: parity_gen reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_parity_gen_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("comparator_parity_gray_tb_parity_gen_smoke.vcd");
        $dumpvars(0, tb_parity_gen_smoke);
    end

endmodule
