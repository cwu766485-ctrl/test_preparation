`timescale 1ns/1ps
// Generated standalone smoke test for gray_ptr_sync.
module tb_gray_ptr_sync_smoke;
    localparam integer W = 4;
    reg src_clk;
    reg dst_clk;
    reg src_rst_n;
    reg dst_rst_n;
    reg [W-1:0] binary_i;
    wire [W-1:0] gray_o;

    gray_ptr_sync dut (
        .src_clk(src_clk),
        .dst_clk(dst_clk),
        .src_rst_n(src_rst_n),
        .dst_rst_n(dst_rst_n),
        .binary_i(binary_i),
        .gray_o(gray_o)
    );
    always #5 src_clk = ~src_clk;
    always #7 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        src_clk = 1'b0;
        dst_clk = 1'b0;
        src_rst_n = 1'b0;
        dst_rst_n = 1'b0;
        binary_i = 0;
        cycle = 0;
        #20;
        src_rst_n = 1'b1;
        dst_rst_n = 1'b1;
        repeat (24) begin
            @(negedge src_clk);
            binary_i = $random;
            #1;
            if ((^gray_o) === 1'bx) begin $display("FAIL: gray_ptr_sync.gray_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: gray_ptr_sync reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_gray_ptr_sync_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("gray_pointer_tb_gray_ptr_sync_smoke.vcd");
        $dumpvars(0, tb_gray_ptr_sync_smoke);
    end

endmodule
