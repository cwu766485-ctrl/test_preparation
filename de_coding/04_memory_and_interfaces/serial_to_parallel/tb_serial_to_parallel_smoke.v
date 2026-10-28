`timescale 1ns/1ps
// Generated standalone smoke test for serial_to_parallel.
module tb_serial_to_parallel_smoke;
    localparam integer W = 8;
    reg clk;
    reg rst_n;
    reg en;
    reg msb_first;
    reg serial_i;
    wire [W-1:0] parallel_o;
    wire valid;

    serial_to_parallel dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .msb_first(msb_first),
        .serial_i(serial_i),
        .parallel_o(parallel_o),
        .valid(valid)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        en = 0;
        msb_first = 1'b1;
        serial_i = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        msb_first = 1'b0;
        repeat (24) begin
            @(negedge clk);
            en = $random;
            serial_i = $random;
            #1;
            if ((^parallel_o) === 1'bx) begin $display("FAIL: serial_to_parallel.parallel_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^valid) === 1'bx) begin $display("FAIL: serial_to_parallel.valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: serial_to_parallel reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_serial_to_parallel_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
