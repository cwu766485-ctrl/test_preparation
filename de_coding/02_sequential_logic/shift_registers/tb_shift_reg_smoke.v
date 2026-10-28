`timescale 1ns/1ps
// Generated standalone smoke test for shift_reg.
module tb_shift_reg_smoke;
    localparam integer W = 8;
    reg clk;
    reg rst_n;
    reg din;
    wire dout;

    shift_reg dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .dout(dout)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        din = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            din = $random;
            #1;
            if ((^dout) === 1'bx) begin $display("FAIL: shift_reg.dout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: shift_reg reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_shift_reg_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("shift_registers_tb_shift_reg_smoke.vcd");
        $dumpvars(0, tb_shift_reg_smoke);
    end

endmodule
