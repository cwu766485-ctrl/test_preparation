`timescale 1ns/1ps
// Generated standalone smoke test for bin_gray.
module tb_bin_gray_smoke;
    localparam integer W = 8;
    reg [W-1:0] bin;
    wire [W-1:0] gray;
    reg [W-1:0] gray_in;
    wire [W-1:0] bin_out;

    bin_gray dut (
        .bin(bin),
        .gray(gray),
        .gray_in(gray_in),
        .bin_out(bin_out)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        bin = 0;
        gray_in = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            bin = $random;
            gray_in = $random;
            #1;
            if ((^gray) === 1'bx) begin $display("FAIL: bin_gray.gray is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^bin_out) === 1'bx) begin $display("FAIL: bin_gray.bin_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: bin_gray reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_bin_gray_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
