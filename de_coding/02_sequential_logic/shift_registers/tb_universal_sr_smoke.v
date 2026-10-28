`timescale 1ns/1ps
// Generated standalone smoke test for universal_sr.
module tb_universal_sr_smoke;
    localparam integer W = 8;
    reg clk;
    reg rst_n;
    reg [1:0] op;
    reg sin;
    reg [W-1:0] par_in;
    wire [W-1:0] q;

    universal_sr dut (
        .clk(clk),
        .rst_n(rst_n),
        .op(op),
        .sin(sin),
        .par_in(par_in),
        .q(q)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        op = 0;
        sin = 0;
        par_in = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            op = $random;
            sin = $random;
            par_in = $random;
            #1;
            if ((^q) === 1'bx) begin $display("FAIL: universal_sr.q is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: universal_sr reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_universal_sr_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
