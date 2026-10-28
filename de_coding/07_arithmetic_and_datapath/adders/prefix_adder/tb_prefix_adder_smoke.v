`timescale 1ns/1ps
// Generated standalone smoke test for prefix_adder.
module tb_prefix_adder_smoke;
    localparam integer WIDTH = 16;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg cin;
    wire [WIDTH-1:0] sum;
    wire cout;

    prefix_adder dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        a = 0;
        b = 0;
        cin = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            a = $random;
            b = $random;
            cin = $random;
            #1;
            if ((^sum) === 1'bx) begin $display("FAIL: prefix_adder.sum is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^cout) === 1'bx) begin $display("FAIL: prefix_adder.cout is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: prefix_adder reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_prefix_adder_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("prefix_adder_tb_prefix_adder_smoke.vcd");
        $dumpvars(0, tb_prefix_adder_smoke);
    end

endmodule
