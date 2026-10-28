`timescale 1ns/1ps
// Generated standalone smoke test for dual_clock_reset_sync.
module tb_dual_clock_reset_sync_smoke;
    localparam integer STAGES = 2;
    reg src_clk;
    reg dst_clk;
    reg async_rst_n;
    wire src_rst_n;
    wire dst_rst_n;

    dual_clock_reset_sync dut (
        .src_clk(src_clk),
        .dst_clk(dst_clk),
        .async_rst_n(async_rst_n),
        .src_rst_n(src_rst_n),
        .dst_rst_n(dst_rst_n)
    );
    always #5 src_clk = ~src_clk;
    always #7 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        src_clk = 1'b0;
        dst_clk = 1'b0;
        async_rst_n = 1'b0;
        cycle = 0;
        #20;
        async_rst_n = 1'b1;
        repeat (24) begin
            @(negedge src_clk);
            #1;
            if ((^src_rst_n) === 1'bx) begin $display("FAIL: dual_clock_reset_sync.src_rst_n is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^dst_rst_n) === 1'bx) begin $display("FAIL: dual_clock_reset_sync.dst_rst_n is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: dual_clock_reset_sync reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_dual_clock_reset_sync_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("reset_synchronizer_tb_dual_clock_reset_sync_smoke.vcd");
        $dumpvars(0, tb_dual_clock_reset_sync_smoke);
    end

endmodule
