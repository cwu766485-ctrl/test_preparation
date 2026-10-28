`timescale 1ns/1ps
// Generated standalone smoke test for multiplier_adder_tree.
module tb_multiplier_adder_tree_smoke;
    localparam integer ROW_WIDTH = 16;
    localparam integer ROWS = 1;
    reg [ROWS*ROW_WIDTH-1:0] rows;
    wire [ROW_WIDTH-1:0] sum;

    multiplier_adder_tree dut (
        .rows(rows),
        .sum(sum)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        rows = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            rows = $random;
            #1;
            if ((^sum) === 1'bx) begin $display("FAIL: multiplier_adder_tree.sum is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: multiplier_adder_tree reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_multiplier_adder_tree_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("pipelined_multiplier_tb_multiplier_adder_tree_smoke.vcd");
        $dumpvars(0, tb_multiplier_adder_tree_smoke);
    end

endmodule
