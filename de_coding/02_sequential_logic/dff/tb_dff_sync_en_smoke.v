`timescale 1ns/1ps
// Generated standalone smoke test for dff_sync_en.
module tb_dff_sync_en_smoke;
    reg clk;
    reg rst;
    reg en;
    reg d;
    wire q;

    dff_sync_en dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .d(d),
        .q(q)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst = 1'b1;
        en = 0;
        d = 0;
        cycle = 0;
        #20;
        rst = 1'b0;
        repeat (24) begin
            @(negedge clk);
            en = $random;
            d = $random;
            #1;
            if ((^q) === 1'bx) begin $display("FAIL: dff_sync_en.q is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: dff_sync_en reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_dff_sync_en_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("dff_tb_dff_sync_en_smoke.vcd");
        $dumpvars(0, tb_dff_sync_en_smoke);
    end

endmodule
