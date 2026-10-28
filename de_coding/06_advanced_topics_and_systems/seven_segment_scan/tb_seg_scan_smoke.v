`timescale 1ns/1ps
// Generated standalone smoke test for seg_scan.
module tb_seg_scan_smoke;
    localparam integer N = 4;
    reg clk;
    reg rst_n;
    reg [N*4-1:0] bcd;
    wire [N-1:0] sel;
    wire [6:0] seg;

    seg_scan dut (
        .clk(clk),
        .rst_n(rst_n),
        .bcd(bcd),
        .sel(sel),
        .seg(seg)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        bcd = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            bcd = $random;
            #1;
            if ((^sel) === 1'bx) begin $display("FAIL: seg_scan.sel is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^seg) === 1'bx) begin $display("FAIL: seg_scan.seg is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: seg_scan reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_seg_scan_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("seven_segment_scan_tb_seg_scan_smoke.vcd");
        $dumpvars(0, tb_seg_scan_smoke);
    end

endmodule
