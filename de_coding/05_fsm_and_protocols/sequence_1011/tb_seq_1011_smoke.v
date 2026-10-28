`timescale 1ns/1ps
// Generated standalone smoke test for seq_1011.
module tb_seq_1011_smoke;
    reg clk;
    reg rst_n;
    reg data;
    wire det;

    seq_1011 dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(data),
        .det(det)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        data = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            data = $random;
            #1;
            if ((^det) === 1'bx) begin $display("FAIL: seq_1011.det is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: seq_1011 reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_seq_1011_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
