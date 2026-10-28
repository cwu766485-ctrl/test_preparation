`timescale 1ns/1ps
// Generated standalone smoke test for bit_sync2.
module tb_bit_sync2_smoke;
    localparam integer STAGES = 2;
    reg dst_clk;
    reg rst_n;
    reg async_i;
    wire sync_o;

    bit_sync2 dut (
        .dst_clk(dst_clk),
        .rst_n(rst_n),
        .async_i(async_i),
        .sync_o(sync_o)
    );
    always #5 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        dst_clk = 1'b0;
        rst_n = 1'b0;
        async_i = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge dst_clk);
            async_i = $random;
            #1;
            if ((^sync_o) === 1'bx) begin $display("FAIL: bit_sync2.sync_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: bit_sync2 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_bit_sync2_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
