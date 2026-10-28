`timescale 1ns/1ps

// Compile ONLY against the synthesized Syn_matrix_mul_2x2.v + GF22 library.f.
// SDF file must match the same synthesis run. Functional checks are made at
// falling edges to allow cell propagation after the active rising clock edge.
module tb_matrix_mul_2x2_gate;
    reg clk;
    reg rst_n;
    reg start;
    reg [31:0] A_flat, B_flat;
    wire [16:0] C00, C01, C10, C11;
    wire busy, done;
    integer gate_cases, k;

    matrix_mul_2x2 dut(
        .clk(clk),.rst_n(rst_n),.start(start),
        .A_flat(A_flat),.B_flat(B_flat),
        .C00(C00),.C01(C01),.C10(C10),.C11(C11),
        .busy(busy),.done(done)
    );

    initial clk=1'b0;
    always #5 clk=~clk; // 10ns clock, matching required synthesis SDC

`ifdef GATE_SDF
    initial $sdf_annotate("Syn_matrix_mul_2x2.sdf", dut);
`endif

    initial begin
`ifdef VCS_VPD
        $vcdplusfile("inter.vpd");
        $vcdpluson(0,tb_matrix_mul_2x2_gate);
`else
        $dumpfile("matrix_mul_2x2_gate.vcd");
        $dumpvars(0,tb_matrix_mul_2x2_gate);
`endif
    end

    task automatic gate_case(input [31:0] aa, input [31:0] bb);
        reg [16:0] e00,e01,e10,e11;
        begin
            e00=(aa[31:24]*bb[31:24])+(aa[23:16]*bb[15:8]);
            e01=(aa[31:24]*bb[23:16])+(aa[23:16]*bb[7:0]);
            e10=(aa[15:8]*bb[31:24])+(aa[7:0]*bb[15:8]);
            e11=(aa[15:8]*bb[23:16])+(aa[7:0]*bb[7:0]);

            gate_cases=gate_cases+1;
            @(negedge clk);
            A_flat=aa; B_flat=bb; start=1'b1;
            @(posedge clk);
            @(negedge clk); #1;
            if (busy !== 1'b1 || done !== 1'b0 ||
                C00 !== 17'd0 || C01 !== 17'd0 ||
                C10 !== 17'd0 || C11 !== 17'd0)
                $fatal(1,"gate start failure case=%0d",gate_cases);
            start=1'b0;

            for (k=1;k<=8;k=k+1) begin
                @(posedge clk);
                @(negedge clk); #1;
                if (busy !== (k<8) || done !== (k==8))
                    $fatal(1,"gate control error case=%0d cycle=%0d",gate_cases,k);
            end
            if (C00 !== e00 || C01 !== e01 ||
                C10 !== e10 || C11 !== e11)
                $fatal(1,"gate data mismatch case=%0d exp=%0d,%0d,%0d,%0d got=%0d,%0d,%0d,%0d",
                       gate_cases,e00,e01,e10,e11,C00,C01,C10,C11);

            @(posedge clk);
            @(negedge clk); #1;
            if (busy !== 1'b0 || done !== 1'b0)
                $fatal(1,"gate done pulse must last one cycle");
            $display("PASS gate case=%0d",gate_cases);
        end
    endtask

    initial begin
        gate_cases=0;
        rst_n=0; start=0; A_flat=0; B_flat=0;
        repeat(2) @(posedge clk);
        @(negedge clk); rst_n=1;
        gate_case({8'd1,8'd2,8'd3,8'd4},
                  {8'd5,8'd6,8'd7,8'd8});
        gate_case({8'd255,8'd255,8'd255,8'd255},
                  {8'd255,8'd255,8'd255,8'd255});
        gate_case(32'd0,32'h12345678);
`ifdef VCS_VPD
        $vcdplusoff;
`endif
        $display("PASS GATE ALL: %0d cases",gate_cases);
        $finish;
    end

    initial begin
        #50000;
        $fatal(1,"GATE TIMEOUT");
    end
endmodule
