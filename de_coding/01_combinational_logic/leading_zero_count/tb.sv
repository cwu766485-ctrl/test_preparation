`timescale 1ns/1ps

module tb_lzc32;

reg  [31:0] din;
wire [5:0] count;
integer errors;

lzc32 dut (
    .din   (din),
    .count (count)
);

initial begin
    errors = 0;
    $fsdbDumpfile("lzc32.fsdb");
    $fsdbDumpvars(0, tb_lzc32);

    din = 32'h8000_0000;
    #10;
    if (count !== 0) begin errors = errors + 1; $display("ERROR1 count=%0d", count); end

    din = 32'h4000_0000;
    #10;
    if (count !== 1) begin errors = errors + 1; $display("ERROR2 count=%0d", count); end

    din = 32'h0800_0000;
    #10;
    if (count !== 4) begin errors = errors + 1; $display("ERROR3 count=%0d", count); end

    din = 32'h0000_0001;
    #10;
    if (count !== 31) begin errors = errors + 1; $display("ERROR4 count=%0d", count); end

    din = 32'h0000_0000;
    #10;
    if (count !== 32) begin errors = errors + 1; $display("ERROR5 count=%0d", count); end

    if (errors == 0) $display("LZC TEST PASS");
    else             $display("LZC TEST FAIL: %0d errors", errors);

    #10;
    $finish;
end

endmodule
