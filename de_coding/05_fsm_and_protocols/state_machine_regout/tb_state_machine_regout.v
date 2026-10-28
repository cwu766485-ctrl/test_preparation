`timescale 1ns/1ps
module tb_state_machine_regout;
    reg clk = 1'b0, rst_n = 1'b0, start = 1'b0, state_reset = 1'b0;
    reg a = 1'b0, b = 1'b0, cin = 1'b0;
    wire sum_out, carry_out;
    integer errors = 0;

    state_machine_regout dut (clk, rst_n, start, state_reset, a, b, cin, sum_out, carry_out);
    always #5 clk = ~clk;

    task check_outputs;
        input expected_sum, expected_carry;
        begin
            #1;
            if ({sum_out, carry_out} !== {expected_sum, expected_carry}) begin
                $display("FAIL: outputs=%b%b expected=%b%b", sum_out, carry_out, expected_sum, expected_carry);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        #12 rst_n = 1'b1;
        @(negedge clk); start = 1'b1;
        @(posedge clk); check_outputs(1'b0, 1'b0);
        @(negedge clk); start = 1'b0; a = 1'b1; b = 1'b0; cin = 1'b0;
        #1; check_outputs(1'b0, 1'b0); // Input changes alone cannot glitch registered outputs.
        @(posedge clk); check_outputs(1'b1, 1'b0); // S1 registers the sum.
        @(negedge clk); a = 1'b1; b = 1'b1; cin = 1'b0;
        @(posedge clk); check_outputs(1'b0, 1'b1); // S2 captures carry.
        @(negedge clk); a = 1'b1; b = 1'b1; cin = 1'b1; state_reset = 1'b1;
        @(posedge clk); check_outputs(1'b1, 1'b1); // S3 registers both outputs.
        @(negedge clk); state_reset = 1'b0;
        @(posedge clk); check_outputs(1'b0, 1'b0);
        if (errors == 0) $display("PASS: FSM outputs change only on clock edges");
        else $display("FAIL: %0d FSM output errors", errors);
        $finish;
    end
    initial begin
        $dumpfile("state_machine_regout_tb_state_machine_regout.vcd");
        $dumpvars(0, tb_state_machine_regout);
    end

endmodule
