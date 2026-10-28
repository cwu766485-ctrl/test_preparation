`timescale 1ns/1ps
// Generated standalone smoke test for strict_priority_arbiter.
module tb_strict_priority_arbiter_smoke;
    reg [3:0] req;
    wire [3:0] grant;
    wire grant_valid;

    strict_priority_arbiter dut (
        .req(req),
        .grant(grant),
        .grant_valid(grant_valid)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        req = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            req = $random;
            #1;
            if ((^grant) === 1'bx) begin $display("FAIL: strict_priority_arbiter.grant is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^grant_valid) === 1'bx) begin $display("FAIL: strict_priority_arbiter.grant_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: strict_priority_arbiter reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_strict_priority_arbiter_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
