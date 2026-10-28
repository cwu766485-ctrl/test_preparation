`timescale 1ns/1ps
// Generated standalone smoke test for reset_synchronizer.
module tb_reset_synchronizer_smoke;
    localparam integer STAGES = 2;
    reg clk;
    reg async_rst_n;
    wire sync_rst_n;

    reset_synchronizer dut (
        .clk(clk),
        .async_rst_n(async_rst_n),
        .sync_rst_n(sync_rst_n)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        async_rst_n = 1'b0;
        cycle = 0;
        #20;
        async_rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            #1;
            if ((^sync_rst_n) === 1'bx) begin $display("FAIL: reset_synchronizer.sync_rst_n is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: reset_synchronizer reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_reset_synchronizer_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
