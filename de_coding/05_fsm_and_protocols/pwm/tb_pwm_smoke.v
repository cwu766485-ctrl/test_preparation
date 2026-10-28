`timescale 1ns/1ps
// Generated standalone smoke test for pwm.
module tb_pwm_smoke;
    localparam integer N = 8;
    reg clk;
    reg rst_n;
    reg [N-1:0] duty;
    wire pwm_out;

    pwm dut (
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty),
        .pwm_out(pwm_out)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        duty = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            duty = $random;
            #1;
            if ((^pwm_out) === 1'bx) begin $display("FAIL: pwm.pwm_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pwm reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pwm_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("pwm_tb_pwm_smoke.vcd");
        $dumpvars(0, tb_pwm_smoke);
    end

endmodule
