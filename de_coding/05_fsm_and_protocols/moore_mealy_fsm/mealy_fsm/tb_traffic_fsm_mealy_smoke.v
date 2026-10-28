`timescale 1ns/1ps
// Generated standalone smoke test for traffic_fsm_mealy.
module tb_traffic_fsm_mealy_smoke;
    reg clk;
    reg rst_n;
    reg start;
    wire [1:0] out;

    traffic_fsm_mealy dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .out(out)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            #1;
            if ((^out) === 1'bx) begin $display("FAIL: traffic_fsm_mealy.out is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: traffic_fsm_mealy reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_traffic_fsm_mealy_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("mealy_fsm_tb_traffic_fsm_mealy_smoke.vcd");
        $dumpvars(0, tb_traffic_fsm_mealy_smoke);
    end

endmodule
