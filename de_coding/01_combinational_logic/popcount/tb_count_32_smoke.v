`timescale 1ns/1ps
// Generated standalone smoke test for count_32.
module tb_count_32_smoke;
    reg clk;
    reg rst_n;
    reg [31:0] data_i;
    reg valid_i;
    wire [5:0] count;
    wire done;

    count_32 dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_i(data_i),
        .valid_i(valid_i),
        .count(count),
        .done(done)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        data_i = 0;
        valid_i = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            data_i = $random;
            valid_i = $random;
            #1;
            if ((^count) === 1'bx) begin $display("FAIL: count_32.count is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: count_32.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: count_32 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_count_32_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
