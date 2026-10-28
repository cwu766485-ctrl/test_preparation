`timescale 1ns/1ps
// ============================================================
// 改错题 2 的测试平台：ref_q 独立实现预期计数器。依次测试计数及溢出、EN=0 保持、CLR 同步清零和 NRST 异步清零；下降沿检查输出，避开上升沿非阻塞赋值的更新时间。时钟周期 20 ns。
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

    // 参考模型独立实现题目规格，不依赖被测模块内部状态。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)    ref_q <= 0;
        else if (CLR) ref_q <= 0;
        else if (EN)  ref_q <= ref_q + 1;
    end

    // 下降沿检查：上升沿更新寄存器后，输出已有时间稳定。
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

        EN = 1;                          // 连续计数 20 拍，覆盖最大值 15 及回绕到 0
        repeat (20) @(negedge CLK);
        EN = 0;                          // 关闭 EN 三拍，检查计数值是否保持
        repeat (3) @(negedge CLK);
        EN = 1; CLR = 1;                 // CLR 与 EN 同时有效时，应优先同步清零
        @(negedge CLK) CLR = 0;
        repeat (5) @(negedge CLK);
        #3 NRST = 0;                     // 在两个有效时钟沿之间拉低复位，专门检查异步行为
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
