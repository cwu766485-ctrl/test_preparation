`timescale 1ns/1ps
// Generated standalone smoke test for async_fifo.
module tb_async_fifo_smoke;
    localparam integer W = 8;
    localparam integer D = 16;
    reg wclk;
    reg rclk;
    reg rst_n;
    reg w_en;
    reg r_en;
    reg [W-1:0] wdata;
    wire [W-1:0] rdata;
    wire full;
    wire empty;

    async_fifo dut (
        .wclk(wclk),
        .rclk(rclk),
        .rst_n(rst_n),
        .w_en(w_en),
        .r_en(r_en),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );
    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        wclk = 1'b0;
        rclk = 1'b0;
        rst_n = 1'b0;
        w_en = 0;
        r_en = 0;
        wdata = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge wclk);
            w_en = $random;
            r_en = $random;
            wdata = $random;
            #1;
            if ((^rdata) === 1'bx) begin $display("FAIL: async_fifo.rdata is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^full) === 1'bx) begin $display("FAIL: async_fifo.full is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^empty) === 1'bx) begin $display("FAIL: async_fifo.empty is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: async_fifo reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_async_fifo_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("async_fifo_tb_async_fifo_smoke.vcd");
        $dumpvars(0, tb_async_fifo_smoke);
    end

endmodule
