`timescale 1ns/1ps
// Generated standalone smoke test for pulse_width.
module tb_pulse_width_smoke;
    reg clk;
    reg rst_n;
    reg sig;
    wire [15:0] width;
    wire done;

    pulse_width dut (
        .clk(clk),
        .rst_n(rst_n),
        .sig(sig),
        .width(width),
        .done(done)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        sig = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            sig = $random;
            #1;
            if ((^width) === 1'bx) begin $display("FAIL: pulse_width.width is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: pulse_width.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pulse_width reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pulse_width_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("pulse_width_tb_pulse_width_smoke.vcd");
        $dumpvars(0, tb_pulse_width_smoke);
    end

endmodule
