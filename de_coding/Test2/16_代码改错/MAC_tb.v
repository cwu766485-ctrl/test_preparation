`timescale 1ns/1ps
// ============================================================
// 改错题 4 的测试平台：用 integer 类型的 ref_acc 计算有符号参考值；上升沿后 2 ns 比较 ACC。先做固定种子的随机输入、EN 和 CLR 测试，再连续累加 16 次 (-128)×(-128) 检查最大正积。时钟周期 20 ns。
// ============================================================
module MAC_tb;
    parameter CLK_T = 10;

    reg                CLK, NRST, CLR, EN;
    reg  signed [7:0]  A, B;
    wire signed [19:0] ACC;

    integer ref_acc, i, seed, errors, log_fd;

    MAC U1 (.CLK(CLK), .NRST(NRST), .CLR(CLR), .EN(EN), .A(A), .B(B), .ACC(ACC));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_MAC.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, MAC_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 参考模型使用整数算术计算期望累加值。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)    ref_acc <= 0;
        else if (CLR) ref_acc <= 0;
        else if (EN)  ref_acc <= ref_acc + A * B;
    end

    // 检查器：比较被测输出与参考结果。
    always @(posedge CLK) begin
        #2;
        if (NRST) begin
            if ($signed(ACC) !== ref_acc) begin
                errors = errors + 1;
                $display ("FAIL t=%0t ACC=%0d expected %0d", $time, $signed(ACC), ref_acc);
                $fdisplay(log_fd, "FAIL t=%0t ACC=%0d expected %0d", $time, $signed(ACC), ref_acc);
            end else
                $fdisplay(log_fd, "PASS t=%0t ACC=%0d", $time, $signed(ACC));
        end
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; seed = 7;
        NRST = 0; CLR = 0; EN = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        // 第一部分：随机操作，覆盖有符号乘法、使能与清零。
        for (i = 0; i < 40; i = i + 1) begin
            @(negedge CLK);
            A   = $random(seed);
            B   = $random(seed);
            EN  = ($random(seed) % 4) != 0;      // EN 约四分之三的时间为 1，以覆盖工作和保持状态
            CLR = (i % 10 == 9);
        end

        // 第二部分：连续 16 次累加最大正乘积 16384
        @(negedge CLK); CLR = 1; EN = 0;
        @(negedge CLK); CLR = 0; EN = 1; A = -128; B = -128;
        repeat (16) @(negedge CLK);
        EN = 0;
        @(negedge CLK);
        $display("worst case ACC = %0d (expected 262144)", $signed(ACC));

        $display ("==== DONE: %0d errors ====", errors);
        $fdisplay(log_fd, "==== DONE: %0d errors ====", errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
