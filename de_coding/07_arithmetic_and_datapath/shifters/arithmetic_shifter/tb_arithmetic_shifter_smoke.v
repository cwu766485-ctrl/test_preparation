`timescale 1ns/1ps
// Generated standalone smoke test for arithmetic_shifter.
module tb_arithmetic_shifter_smoke;
    localparam integer WIDTH = 8;
    localparam integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH);
    reg signed [WIDTH-1:0] din;
    reg [SHAMT_WIDTH-1:0] shamt;
    wire signed [WIDTH-1:0] dout;

    arithmetic_shifter dut (
        .din(din),
        .shamt(shamt),
        .dout(dout)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        din = 0;
        shamt = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            din = $random;
            shamt = $random;
            #1;
            if ((^dout) === 1'bx) begin $display("FAIL: arithmetic_shifter.dout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: arithmetic_shifter reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_arithmetic_shifter_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("arithmetic_shifter_tb_arithmetic_shifter_smoke.vcd");
        $dumpvars(0, tb_arithmetic_shifter_smoke);
    end

endmodule
