`timescale 1ns/1ps
// Generated standalone smoke test for password_lock.
module tb_password_lock_smoke;
    reg clk;
    reg rst_n;
    reg key_valid;
    reg [3:0] key_data;
    wire unlock;
    wire alarm;

    password_lock dut (
        .clk(clk),
        .rst_n(rst_n),
        .key_valid(key_valid),
        .key_data(key_data),
        .unlock(unlock),
        .alarm(alarm)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        key_valid = 0;
        key_data = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            key_valid = $random;
            key_data = $random;
            #1;
            if ((^unlock) === 1'bx) begin $display("FAIL: password_lock.unlock is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^alarm) === 1'bx) begin $display("FAIL: password_lock.alarm is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: password_lock reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_password_lock_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
