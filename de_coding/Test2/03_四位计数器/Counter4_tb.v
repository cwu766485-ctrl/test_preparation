`timescale 1ns/1ps
// ============================================================
// 测试平台：检查 4 位计数器的逐拍行为。
// 独立参考计数器 ref_q 与设计同时运行，每一拍比较一次。
// 覆盖正常计数与回绕、EN=0 保持、同步清零及异步复位。
// 完整时钟周期为 2×CLK_T=20 ns。
// ============================================================
module Counter4_tb;
    parameter CLK_T = 10;

    reg        CLK, NRST, CLR, EN;
    wire [3:0] Q;
    wire       TC;

    reg  [3:0] ref_q;
    integer    errors, log_fd;

    Counter4 U1 (.CLK(CLK), .NRST(NRST), .CLR(CLR), .EN(EN), .Q(Q), .TC(TC));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_Counter4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, Counter4_tb);
    end
`endif

    initial begin
        CLK = 0;
        forever #CLK_T CLK = !CLK;
    end

    // 参考模型独立描述同一规格，不读取设计内部 Q。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)    ref_q <= 0;
        else if (CLR) ref_q <= 0;
        else if (EN)  ref_q <= ref_q + 1;
    end

    // 在下降沿比较，输出已在上一个上升沿稳定。
    always @(negedge CLK) if (NRST) begin
        if (Q !== ref_q || TC !== (EN && ref_q == 15)) begin
            errors = errors + 1;
            $display ("FAIL t=%0t Q=%0d expected %0d TC=%b", $time, Q, ref_q, TC);
            $fdisplay(log_fd, "FAIL t=%0t Q=%0d expected %0d TC=%b", $time, Q, ref_q, TC);
        end else
            $fdisplay(log_fd, "PASS t=%0t EN=%b CLR=%b Q=%0d TC=%b", $time, EN, CLR, Q, TC);
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; NRST = 0; CLR = 0; EN = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        EN = 1;                          // 连续计数 20 拍，确保经过 15 回绕到 0。
        repeat (20) @(negedge CLK);
        EN = 0;                          // 关闭使能 3 拍，检查 Q 是否保持。
        repeat (3) @(negedge CLK);
        EN = 1; CLR = 1;                 // 同时置 EN 与 CLR，验证清零优先于加一。
        @(negedge CLK) CLR = 0;
        repeat (5) @(negedge CLK);
        #3 NRST = 0;                     // 在时钟周期中间拉低 NRST，检查异步清零。
        #2 if (Q !== 0) begin errors = errors + 1; $display("FAIL: async reset"); end
        @(negedge CLK) NRST = 1;
        repeat (2) @(negedge CLK);

        $display ("==== DONE: final Q=%0d, %0d errors ====", Q, errors);
        $fdisplay(log_fd, "==== DONE: final Q=%0d, %0d errors ====", Q, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
