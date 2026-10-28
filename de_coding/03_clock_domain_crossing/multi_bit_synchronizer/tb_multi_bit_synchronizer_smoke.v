`timescale 1ns/1ps
// Generated standalone smoke test for multi_bit_synchronizer.
module tb_multi_bit_synchronizer_smoke;
    localparam integer W = 8;
    reg src_clk;
    reg dst_clk;
    reg rst_n;
    reg src_valid;
    reg [W-1:0] src_data;
    wire src_ready;
    wire dst_valid;
    wire [W-1:0] dst_data;

    multi_bit_synchronizer dut (
        .src_clk(src_clk),
        .dst_clk(dst_clk),
        .rst_n(rst_n),
        .src_valid(src_valid),
        .src_data(src_data),
        .src_ready(src_ready),
        .dst_valid(dst_valid),
        .dst_data(dst_data)
    );
    always #5 src_clk = ~src_clk;
    always #7 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        src_clk = 1'b0;
        dst_clk = 1'b0;
        rst_n = 1'b0;
        src_valid = 0;
        src_data = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge src_clk);
            src_valid = $random;
            src_data = $random;
            #1;
            if ((^src_ready) === 1'bx) begin $display("FAIL: multi_bit_synchronizer.src_ready is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^dst_valid) === 1'bx) begin $display("FAIL: multi_bit_synchronizer.dst_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^dst_data) === 1'bx) begin $display("FAIL: multi_bit_synchronizer.dst_data is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: multi_bit_synchronizer reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_multi_bit_synchronizer_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
