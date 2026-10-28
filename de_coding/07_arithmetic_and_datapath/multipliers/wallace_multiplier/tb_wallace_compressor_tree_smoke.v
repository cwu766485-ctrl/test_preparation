`timescale 1ns/1ps
// Generated standalone smoke test for wallace_compressor_tree.
module tb_wallace_compressor_tree_smoke;
    localparam integer ROW_WIDTH = 16;
    localparam integer ROWS = 1;
    reg [ROWS*ROW_WIDTH-1:0] rows;
    wire [ROW_WIDTH-1:0] row_0;
    wire [ROW_WIDTH-1:0] row_1;

    wallace_compressor_tree dut (
        .rows(rows),
        .row_0(row_0),
        .row_1(row_1)
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
            if ((^row_0) === 1'bx) begin $display("FAIL: wallace_compressor_tree.row_0 is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^row_1) === 1'bx) begin $display("FAIL: wallace_compressor_tree.row_1 is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: wallace_compressor_tree reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_wallace_compressor_tree_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("wallace_multiplier_tb_wallace_compressor_tree_smoke.vcd");
        $dumpvars(0, tb_wallace_compressor_tree_smoke);
    end

endmodule
