`timescale 1ns/1ps
// Generated standalone smoke test for matrix_multiplier.
module tb_matrix_multiplier_smoke;
    localparam integer N = 4;
    localparam integer WIDTH = 8;
    localparam integer ACC_WIDTH = 2 * WIDTH + ((N <= 1) ? 0 : $clog2(N));
    reg clk;
    reg rst_n;
    reg start;
    reg [N*N*WIDTH-1:0] matrix_a;
    reg [N*N*WIDTH-1:0] matrix_b;
    wire [N*N*ACC_WIDTH-1:0] matrix_c;
    wire busy;
    wire done;

    matrix_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .matrix_c(matrix_c),
        .busy(busy),
        .done(done)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        matrix_a = 0;
        matrix_b = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            matrix_a = $random;
            matrix_b = $random;
            #1;
            if ((^matrix_c) === 1'bx) begin $display("FAIL: matrix_multiplier.matrix_c is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^busy) === 1'bx) begin $display("FAIL: matrix_multiplier.busy is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: matrix_multiplier.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: matrix_multiplier reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_matrix_multiplier_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
