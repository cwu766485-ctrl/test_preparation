`timescale 1ns/1ps
module tb_seq_det_101_moore;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg din = 1'b0;
    wire detected;
    reg [2:0] history = 3'b000;
    integer errors = 0;

    seq_det_101_moore dut (
        .clk(clk), .rst_n(rst_n), .din(din), .detected(detected)
    );

    always #5 clk = ~clk;

    task send_bit;
        input bit_value;
        reg expected;
        begin
            @(negedge clk);
            din = bit_value;
            history = {history[1:0], bit_value};
            expected = (history == 3'b101);
            @(posedge clk);
            #1;
            if (detected !== expected) begin
                $display("FAIL: history=%03b detected=%b expected=%b", history, detected, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        #12 rst_n = 1'b1;
        send_bit(1'b1);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        send_bit(1'b0);
        send_bit(1'b1);
        if (errors == 0) $display("PASS: Moore 101 detector, including overlap");
        else $display("FAIL: %0d sequence detector errors", errors);
        $finish;
    end
    initial begin
        $dumpfile("sequence_101_moore_tb_seq_det_101_moore.vcd");
        $dumpvars(0, tb_seq_det_101_moore);
    end

endmodule
