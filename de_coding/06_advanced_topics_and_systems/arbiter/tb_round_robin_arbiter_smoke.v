`timescale 1ns/1ps
// Generated standalone smoke test for round_robin_arbiter.
module tb_round_robin_arbiter_smoke;
    reg clk;
    reg rst_n;
    reg [3:0] req;
    reg grant_accept;
    wire [3:0] grant;
    wire grant_valid;

    round_robin_arbiter dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .grant_accept(grant_accept),
        .grant(grant),
        .grant_valid(grant_valid)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        req = 0;
        grant_accept = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            req = $random;
            grant_accept = $random;
            #1;
            if ((^grant) === 1'bx) begin $display("FAIL: round_robin_arbiter.grant is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^grant_valid) === 1'bx) begin $display("FAIL: round_robin_arbiter.grant_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: round_robin_arbiter reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_round_robin_arbiter_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("arbiter_tb_round_robin_arbiter_smoke.vcd");
        $dumpvars(0, tb_round_robin_arbiter_smoke);
    end

endmodule
