`timescale 1ns/1ps
module tb_vending_machine;
    reg clk=1'b0, rst_n=1'b0, coin_5=1'b0, coin_10=1'b0;
    wire dispense;
    wire [4:0] change, credit;
    vending_machine dut (clk, rst_n, coin_5, coin_10, dispense, change, credit);
    always #5 clk=~clk;

    task insert_coin;
        input use_ten;
        input [4:0] expected_credit;
        input expected_dispense;
        input [4:0] expected_change;
        begin
            @(negedge clk); coin_5=!use_ten; coin_10=use_ten;
            @(posedge clk); #1;
            if (credit !== expected_credit || dispense !== expected_dispense || change !== expected_change) begin
                $display("FAIL: credit=%0d dispense=%b change=%0d", credit, dispense, change);
                $finish;
            end
            @(negedge clk); coin_5=0; coin_10=0;
        end
    endtask

    initial begin
        #12 rst_n=1'b1;
        insert_coin(1'b0, 5, 0, 0);
        insert_coin(1'b1, 0, 1, 0);
        insert_coin(1'b1, 10, 0, 0);
        insert_coin(1'b1, 0, 1, 5);
        insert_coin(1'b0, 5, 0, 0);
        insert_coin(1'b0, 10, 0, 0);
        insert_coin(1'b0, 0, 1, 0);
        $display("PASS: vending, change, and credit reset");
        $finish;
    end
    initial begin
        $dumpfile("vending_machine_tb_vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);
    end

endmodule
