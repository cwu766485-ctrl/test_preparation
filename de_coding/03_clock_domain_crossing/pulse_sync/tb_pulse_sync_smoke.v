`timescale 1ns/1ps
// Generated standalone smoke test for pulse_sync.
module tb_pulse_sync_smoke;
    reg src_clk;
    reg dst_clk;
    reg rst_n;
    reg pulse_i;
    wire pulse_o;

    pulse_sync dut (
        .src_clk(src_clk),
        .dst_clk(dst_clk),
        .rst_n(rst_n),
        .pulse_i(pulse_i),
        .pulse_o(pulse_o)
    );
    always #5 src_clk = ~src_clk;
    always #7 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        src_clk = 1'b0;
        dst_clk = 1'b0;
        rst_n = 1'b0;
        pulse_i = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge src_clk);
            pulse_i = $random;
            #1;
            if ((^pulse_o) === 1'bx) begin $display("FAIL: pulse_sync.pulse_o is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: pulse_sync reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_pulse_sync_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
