`timescale 1ns/1ps

module tb_cnt_up;
    localparam integer WIDTH = 4;

    reg clk;
    reg rst_n;
    reg en;
    wire [WIDTH-1:0] cnt;
    reg [WIDTH-1:0] expected;
    integer i;

    cnt_up #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .cnt(cnt)
    );

    always #5 clk = ~clk;

    task check_after_clock;
        input [WIDTH-1:0] value;
        begin
            @(posedge clk);
            #1;
            if (cnt !== value)
                $fatal(1, "cnt_up expected %0d, got %0d", value, cnt);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        en = 1'b0;
        expected = 0;
        #2;
        if (cnt !== 0)
            $fatal(1, "cnt_up did not asynchronously reset to 0");
        #5 rst_n = 1'b1;

        check_after_clock(0); // Disabled counter holds.

        @(negedge clk);
        en = 1'b1;
        expected = 0;
        for (i = 0; i < 18; i = i + 1) begin
            expected = expected + 1'b1;
            check_after_clock(expected);
        end

        @(negedge clk);
        en = 1'b0;
        check_after_clock(expected);
        check_after_clock(expected);

        $display("PASS: cnt_up counts 0..15, wraps, and holds when disabled");
        $finish;
    end
    initial begin
        $dumpfile("counters_tb_cnt_up.vcd");
        $dumpvars(0, tb_cnt_up);
    end

endmodule
