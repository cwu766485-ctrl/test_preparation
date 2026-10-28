`timescale 1ns/1ps
// Generated standalone smoke test for barrel_shifter.
module tb_barrel_shifter_smoke;
    localparam integer WIDTH = 8;
    localparam integer SHAMT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH);
    reg [WIDTH-1:0] din;
    reg [SHAMT_WIDTH-1:0] shamt;
    reg dir;
    wire [WIDTH-1:0] dout;

    barrel_shifter dut (
        .din(din),
        .shamt(shamt),
        .dir(dir),
        .dout(dout)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        din = 0;
        shamt = 0;
        dir = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            din = $random;
            shamt = $random;
            dir = $random;
            #1;
            if ((^dout) === 1'bx) begin $display("FAIL: barrel_shifter.dout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: barrel_shifter reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_barrel_shifter_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
