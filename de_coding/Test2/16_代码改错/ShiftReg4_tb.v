`timescale 1ns/1ps
// ============================================================
// 改错题 1 的测试平台：随机输入 SIN 和 EN，参考模型 ref_q 用正确的非阻塞移位更新。上升沿后 2 ns 检查 Q、SOUT；最后在两个时钟沿之间拉低 NRST，检查异步清零。
// ============================================================
module ShiftReg4_tb;
    parameter CLK_T = 10;

    reg        CLK, NRST, EN, SIN;
    wire [3:0] Q;
    wire       SOUT;
    reg  [3:0] ref_q;
    integer    i, seed, errors, log_fd;

    ShiftReg4 U1 (.CLK(CLK), .NRST(NRST), .EN(EN), .SIN(SIN), .Q(Q), .SOUT(SOUT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ShiftReg4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ShiftReg4_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    always @(posedge CLK or negedge NRST) begin
        if (!NRST)   ref_q <= 0;
        else if (EN) ref_q <= {ref_q[2:0], SIN};
    end

    always @(posedge CLK) begin
        #2;
        if (NRST) begin
            if (Q !== ref_q || SOUT !== ref_q[3]) begin
                errors = errors + 1;
                $display ("FAIL t=%0t Q=%b expected %b", $time, Q, ref_q);
                $fdisplay(log_fd, "FAIL t=%0t Q=%b expected %b", $time, Q, ref_q);
            end else
                $fdisplay(log_fd, "PASS t=%0t EN=%b SIN=%b Q=%b", $time, EN, SIN, Q);
        end
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; seed = 3;
        NRST = 0; EN = 0; SIN = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;
        for (i = 0; i < 30; i = i + 1) begin
            @(negedge CLK);
            SIN = $random(seed);
            EN  = (i < 4) ? 1'b1 : (($random(seed) % 4) != 0);
        end
        @(negedge CLK); #3 NRST = 0; #1;
        if (Q !== 0) begin errors = errors + 1; $display("FAIL: async reset"); end

        $display ("==== DONE: %0d errors ====", errors);
        $fdisplay(log_fd, "==== DONE: %0d errors ====", errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
