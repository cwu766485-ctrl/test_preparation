`timescale 1ns/1ps
// Generated standalone smoke test for edge_detect.
module tb_edge_detect_smoke;
    reg clk;
    reg rst_n;
    reg data;
    wire pos_edge;
    wire neg_edge;
    wire data_edge;

    edge_detect dut (
        .clk(clk),
        .rst_n(rst_n),
        .data(data),
        .pos_edge(pos_edge),
        .neg_edge(neg_edge),
        .data_edge(data_edge)
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
            if ((^pos_edge) === 1'bx) begin $display("FAIL: edge_detect.pos_edge is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^neg_edge) === 1'bx) begin $display("FAIL: edge_detect.neg_edge is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^data_edge) === 1'bx) begin $display("FAIL: edge_detect.data_edge is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: edge_detect reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_edge_detect_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
