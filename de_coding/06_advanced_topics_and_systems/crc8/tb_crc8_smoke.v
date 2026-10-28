`timescale 1ns/1ps
// Generated standalone smoke test for crc8.
module tb_crc8_smoke;
    reg clk;
    reg rst_n;
    reg data_in;
    reg data_valid;
    wire [7:0] crc;
    wire crc_valid;

    crc8 dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .crc(crc),
        .crc_valid(crc_valid)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        data_in = 0;
        data_valid = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            data_in = $random;
            data_valid = $random;
            #1;
            if ((^crc) === 1'bx) begin $display("FAIL: crc8.crc is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^crc_valid) === 1'bx) begin $display("FAIL: crc8.crc_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: crc8 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_crc8_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("crc8_tb_crc8_smoke.vcd");
        $dumpvars(0, tb_crc8_smoke);
    end

endmodule
