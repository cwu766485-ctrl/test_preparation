`timescale 1ns/1ps
// Generated standalone smoke test for lfsr4.
module tb_lfsr4_smoke;
    reg clk;
    reg rst_n;
    reg en;
    wire [3:0] lfsr;

    lfsr4 dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .lfsr(lfsr)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        en = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            en = $random;
            #1;
            if ((^lfsr) === 1'bx) begin $display("FAIL: lfsr4.lfsr is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: lfsr4 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_lfsr4_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("lfsr_tb_lfsr4_smoke.vcd");
        $dumpvars(0, tb_lfsr4_smoke);
    end

endmodule
