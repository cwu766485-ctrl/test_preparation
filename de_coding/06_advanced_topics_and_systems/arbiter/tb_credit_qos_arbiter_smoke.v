`timescale 1ns/1ps
// Generated standalone smoke test for credit_qos_arbiter.
module tb_credit_qos_arbiter_smoke;
    localparam integer CREDIT_W = 8;
    localparam integer REPLENISH_PERIOD = 256;
    localparam integer WEIGHT0 = 1;
    localparam integer WEIGHT1 = 2;
    localparam integer WEIGHT2 = 4;
    localparam integer WEIGHT3 = 8;
    reg clk;
    reg rst_n;
    reg [3:0] req;
    reg grant_accept;
    wire [3:0] grant;
    wire grant_valid;
    wire [CREDIT_W-1:0] credit0;
    wire [CREDIT_W-1:0] credit1;
    wire [CREDIT_W-1:0] credit2;
    wire [CREDIT_W-1:0] credit3;

    credit_qos_arbiter dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .grant_accept(grant_accept),
        .grant(grant),
        .grant_valid(grant_valid),
        .credit0(credit0),
        .credit1(credit1),
        .credit2(credit2),
        .credit3(credit3)
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
            if ((^grant) === 1'bx) begin $display("FAIL: credit_qos_arbiter.grant is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^grant_valid) === 1'bx) begin $display("FAIL: credit_qos_arbiter.grant_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^credit0) === 1'bx) begin $display("FAIL: credit_qos_arbiter.credit0 is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^credit1) === 1'bx) begin $display("FAIL: credit_qos_arbiter.credit1 is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^credit2) === 1'bx) begin $display("FAIL: credit_qos_arbiter.credit2 is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^credit3) === 1'bx) begin $display("FAIL: credit_qos_arbiter.credit3 is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: credit_qos_arbiter reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_credit_qos_arbiter_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
