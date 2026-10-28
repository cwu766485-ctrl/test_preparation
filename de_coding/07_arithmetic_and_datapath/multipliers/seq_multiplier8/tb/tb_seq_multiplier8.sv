`timescale 1ns/1ps
module tb_seq_multiplier8;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg start = 1'b0;
    reg [7:0] a = 0, b = 0;
    wire [15:0] product;
    wire busy, done;
    integer tests = 0, i;
    reg [15:0] expected, previous_product;
    always #5 clk = ~clk;

    seq_multiplier8 dut(.clk(clk), .rst_n(rst_n), .start(start),
                        .a(a), .b(b), .product(product), .busy(busy), .done(done));
`ifdef GATE_SDF
    initial $sdf_annotate("Syn_seq_multiplier8.sdf", dut);
`endif
`ifdef VCS_VPD
    initial begin $vcdplusfile("inter.vpd"); $vcdpluson(0, tb_seq_multiplier8); end
`else
    initial begin $dumpfile("mock4.vcd"); $dumpvars(0, tb_seq_multiplier8); end
`endif

    task automatic do_multiply(input [7:0] aa, input [7:0] bb);
        integer j;
        begin
            expected = {8'd0,aa} * {8'd0,bb};
            previous_product = product;
            @(negedge clk); a = aa; b = bb; start = 1;
            @(posedge clk); #1;
            if (!busy || done || product !== previous_product)
                $fatal(1, "Mock4 start/busy/hold failure");
            @(negedge clk); start = 0;
            // Inputs change during BUSY; internal operands must not change.
            a = ~aa; b = ~bb;
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge clk); #1;
                if (j < 7) begin
                    if (!busy || done || product !== previous_product)
                        $fatal(1, "Mock4 intermediate cycle=%0d", j);
                end else if (busy || !done || product !== expected)
                    $fatal(1, "Mock4 product %0d*%0d expected %0d got %0d", aa,bb,expected,product);
                // Inject a new start during BUSY; it must be ignored.
                if (j == 2) begin @(negedge clk); start = 1; a = 99; b = 99; end
                if (j == 3) begin @(negedge clk); start = 0; end
            end
            @(posedge clk); #1;
            if (done || busy || product !== expected)
                $fatal(1,"Mock4 done not single-cycle / result not held");
            tests = tests + 1;
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1;
        do_multiply(0,0);
        do_multiply(1,255);
        do_multiply(255,255);
        do_multiply(128,128);
        do_multiply(13,17);
        for (i=0; i<50; i=i+1) do_multiply($urandom_range(0,255), $urandom_range(0,255));
        // Mid-transaction asynchronous reset.
        @(negedge clk); start=1; a=255; b=21;
        @(posedge clk); #1;
        @(negedge clk); start=0;
        @(posedge clk); #1;
        rst_n=0; #1;
        if (busy !== 0 || done !== 0 || product !== 0)
            $fatal(1,"Mock4 asynchronous reset failed");
        @(negedge clk); rst_n=1;
        do_multiply(7,9);
        $display("PASS Mock4 seq_multiplier8 cases=%0d", tests);
        $finish;
    end
    initial begin #200000; $fatal(1,"Mock4 timeout"); end
endmodule
