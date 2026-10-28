`timescale 1ns/1ps
// Generated standalone smoke test for parallel_to_serial.
module tb_parallel_to_serial_smoke;
    localparam integer W = 8;
    reg clk;
    reg rst_n;
    reg load;
    reg en;
    reg [W-1:0] parallel_i;
    wire serial_o;
    wire busy;

    parallel_to_serial dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .en(en),
        .parallel_i(parallel_i),
        .serial_o(serial_o),
        .busy(busy)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        load = 0;
        en = 0;
        parallel_i = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            load = $random;
            en = $random;
            parallel_i = $random;
            #1;
            if ((^serial_o) === 1'bx) begin $display("FAIL: parallel_to_serial.serial_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^busy) === 1'bx) begin $display("FAIL: parallel_to_serial.busy is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: parallel_to_serial reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_parallel_to_serial_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("parallel_to_serial_tb_parallel_to_serial_smoke.vcd");
        $dumpvars(0, tb_parallel_to_serial_smoke);
    end

endmodule
