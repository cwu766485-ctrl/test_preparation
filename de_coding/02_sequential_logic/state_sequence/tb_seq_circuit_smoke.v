`timescale 1ns/1ps
// Generated standalone smoke test for seq_circuit.
module tb_seq_circuit_smoke;
    reg A;
    reg clk;
    reg rst_n;
    wire Y;

    seq_circuit dut (
        .A(A),
        .clk(clk),
        .rst_n(rst_n),
        .Y(Y)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        A = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            A = $random;
            #1;
            if ((^Y) === 1'bx) begin $display("FAIL: seq_circuit.Y is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: seq_circuit reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_seq_circuit_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
