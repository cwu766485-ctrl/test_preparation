`timescale 1ns/1ps
// Generated standalone smoke test for sync_fifo.
module tb_sync_fifo_smoke;
    localparam integer W = 8;
    localparam integer D = 16;
    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    reg [W-1:0] wdata;
    wire [W-1:0] rdata;
    wire full;
    wire empty;

    sync_fifo dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        wr_en = 0;
        rd_en = 0;
        wdata = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            wr_en = $random;
            rd_en = $random;
            wdata = $random;
            #1;
            if ((^rdata) === 1'bx) begin $display("FAIL: sync_fifo.rdata is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^full) === 1'bx) begin $display("FAIL: sync_fifo.full is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^empty) === 1'bx) begin $display("FAIL: sync_fifo.empty is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: sync_fifo reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_sync_fifo_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("sync_fifo_tb_sync_fifo_smoke.vcd");
        $dumpvars(0, tb_sync_fifo_smoke);
    end

endmodule
