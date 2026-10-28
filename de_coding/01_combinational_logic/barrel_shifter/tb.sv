`timescale 1ns/1ps

module tb_barrel_shifter;

reg  [7:0] din;
reg  [2:0] shamt;
reg        dir;

wire [7:0] dout;

barrel_shifter #(
    .W(8)
) dut (
    .din   (din),
    .shamt (shamt),
    .dir   (dir),
    .dout  (dout)
);

initial begin
    $fsdbDumpfile("barrel_shifter.fsdb");
    $fsdbDumpvars(0, tb_barrel_shifter);

    din = 8'b1011_0011;

    // left shift
    dir = 0;

    shamt = 0;
    #10;
    if (dout !== 8'b1011_0011)
        $display("ERROR L0");

    shamt = 1;
    #10;
    if (dout !== 8'b0110_0110)
        $display("ERROR L1");

    shamt = 2;
    #10;
    if (dout !== 8'b1100_1100)
        $display("ERROR L2");

    // right shift
    dir = 1;

    shamt = 1;
    #10;
    if (dout !== 8'b0101_1001)
        $display("ERROR R1");

    shamt = 2;
    #10;
    if (dout !== 8'b0010_1100)
        $display("ERROR R2");

    $display("BARREL SHIFTER TEST PASS");

    #10;
    $finish;
end

endmodule