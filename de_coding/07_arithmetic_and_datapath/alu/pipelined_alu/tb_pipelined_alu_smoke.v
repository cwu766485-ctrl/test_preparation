`timescale 1ns/1ps
// Generated standalone smoke test for pipelined_alu.
module tb_pipelined_alu_smoke;
    localparam integer WIDTH = 8;
    reg clk;
    reg rst_n;
    reg valid_i;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [2:0] op;
    wire valid_o;
    wire [WIDTH-1:0] result;
    wire zero;

    pipelined_alu dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_i(valid_i),
        .a(a),
        .b(b),
        .op(op),
        .valid_o(valid_o),
        .result(result),
        .zero(zero)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        valid_i = 0;
        a = 0;
        b = 0;
        op = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            valid_i = $random;
            a = $random;
            b = $random;
            op = $random;
            #1;
            if ((^valid_o) === 1'bx) begin $display("FAIL: pipelined_alu.valid_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^result) === 1'bx) begin $display("FAIL: pipelined_alu.result is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^zero) === 1'bx) begin $display("FAIL: pipelined_alu.zero is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pipelined_alu reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pipelined_alu_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
