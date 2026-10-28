`timescale 1ns/1ps
// Post-synthesis smoke/regression bench for four-M synthesized top only.
// SDF annotation requires that netlist and SDF match the synthesis run.
module tb_secret_code_gate;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic activate = 1'b0;
    logic [11:0] secret_code = 12'o1145;
    wire [11:0] candidate;
    wire [3:0] match_bits;
    wire busy, relay_open;
    integer k;

    always #5 clk = ~clk;
    secret_code_four dut (
        .clk(clk), .rst_n(rst_n), .activate(activate),
        .secret_code(secret_code), .candidate(candidate),
        .match_bits(match_bits), .busy(busy), .relay_open(relay_open)
    );

`ifdef GATE_SDF
    initial $sdf_annotate("Syn_secret_code_four.sdf", dut);
`endif
    initial begin
`ifdef VCS_VPD
        $vcdpluson(0, tb_secret_code_gate);
`else
        $dumpfile("secret_code_gate.vcd");
        $dumpvars(0, tb_secret_code_gate);
`endif
    end
    initial begin
        @(negedge clk); rst_n = 1'b1;
        @(negedge clk); activate = 1'b1;
        @(posedge clk); #1;
        if (candidate !== 12'd0 || relay_open !== 1'b0 ||
            busy !== 1'b1) $fatal(1, "gate start failed");
        @(negedge clk); activate = 1'b0;
        for (k = 0; k <= int'(secret_code); k++) begin
            @(posedge clk); #1;
            if (k == int'(secret_code)) begin
                if (candidate !== secret_code || relay_open !== 1'b1 ||
                    busy !== 1'b0 || match_bits !== 4'hF)
                    $fatal(1, "gate match failed at %0d", k);
            end else if (candidate !== 12'(k+1) ||
                         relay_open !== 1'b0 || busy !== 1'b1)
                $fatal(1, "gate candidate failed at %0d", k);
        end
        $display("PASS gate simulation target=%04o", secret_code);
        $finish;
    end
    initial begin #150000; $fatal(1,"gate timeout"); end
endmodule
