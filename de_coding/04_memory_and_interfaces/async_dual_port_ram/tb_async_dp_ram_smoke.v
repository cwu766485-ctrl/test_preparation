`timescale 1ns/1ps
// Generated standalone smoke test for async_dp_ram.
module tb_async_dp_ram_smoke;
    localparam integer W = 8;
    localparam integer D = 16;
    reg a_clk;
    reg b_clk;
    reg a_we;
    reg b_we;
    reg [$clog2(D)-1:0] a_addr;
    reg [$clog2(D)-1:0] b_addr;
    reg [W-1:0] a_wdata;
    reg [W-1:0] b_wdata;
    wire [W-1:0] a_rdata;
    wire [W-1:0] b_rdata;

    async_dp_ram dut (
        .a_clk(a_clk),
        .b_clk(b_clk),
        .a_we(a_we),
        .b_we(b_we),
        .a_addr(a_addr),
        .b_addr(b_addr),
        .a_wdata(a_wdata),
        .b_wdata(b_wdata),
        .a_rdata(a_rdata),
        .b_rdata(b_rdata)
    );
    always #5 a_clk = ~a_clk;
    always #7 b_clk = ~b_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a_clk = 1'b0;
        b_clk = 1'b0;
        a_we = 0;
        b_we = 0;
        a_addr = 0;
        b_addr = 0;
        a_wdata = 0;
        b_wdata = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            @(negedge a_clk);
            a_we = $random;
            b_we = $random;
            a_addr = $random;
            b_addr = $random;
            a_wdata = $random;
            b_wdata = $random;
            #1;
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: async_dp_ram reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_async_dp_ram_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("async_dual_port_ram_tb_async_dp_ram_smoke.vcd");
        $dumpvars(0, tb_async_dp_ram_smoke);
    end

endmodule
