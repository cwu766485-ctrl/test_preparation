`timescale 1ns/1ps

module tb_cnt_modN;
    localparam integer N = 10;
    localparam integer WIDTH = $clog2(N);

    reg clk;
    reg rst_n;
    reg en;
    wire [WIDTH-1:0] cnt;
    wire tc;
    integer expected;
    integer i;

    cnt_modN #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .cnt(cnt), .tc(tc)
    );

    always #5 clk = ~clk;

    task check_after_clock;
        input integer value;
        begin
            @(posedge clk);
            #1;
            if (cnt !== value[WIDTH-1:0])
                $fatal(1, "cnt_modN expected %0d, got %0d", value, cnt);
            if (tc !== (value == N-1))
                $fatal(1, "cnt_modN tc mismatch at count %0d (tc=%b)", value, tc);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        en = 1'b0;
        expected = 0;
        #2;
        if (cnt !== 0 || tc !== 1'b0)
            $fatal(1, "cnt_modN reset outputs are incorrect");
        #5 rst_n = 1'b1;

        check_after_clock(0); // Disabled counter holds.

        @(negedge clk);
        en = 1'b1;
        for (i = 0; i < 10; i = i + 1) begin
            expected = (expected == N-1) ? 0 : expected + 1;
            check_after_clock(expected);
        end

        // Reach N-1 again to test holding the terminal count while disabled.
        for (i = 0; i < N-1; i = i + 1) begin
            expected = expected + 1;
            check_after_clock(expected);
        end

        // At N-1, disabling holds both the count and terminal-count flag.
        @(negedge clk);
        en = 1'b0;
        expected = N - 1;
        check_after_clock(expected);
        @(negedge clk);
        en = 1'b1;
        expected = 0;
        check_after_clock(expected);

        $display("PASS: cnt_modN cycles 0..%0d and asserts tc at N-1", N-1);
        $finish;
    end
    initial begin
        $dumpfile("counters_tb_cnt_modN.vcd");
        $dumpvars(0, tb_cnt_modN);
    end

endmodule
