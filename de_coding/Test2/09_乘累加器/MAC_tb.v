`timescale 1ns/1ps
// ============================================================
// 测试平台：检查乘累加器的逐拍结果。
// 使用固定随机种子的有符号 A/B 与随机 EN，每十拍测试一次 CLR。
// 独立整数参考值 ref_acc 在每个上升沿更新，2 ns 后比较 ACC。
// 另外用 16 次 (-128)×(-128) 测试较大的连续累加值。
// 完整时钟周期为 2×CLK_T=20 ns。
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

    // 整数参考模型，按 NRST、CLR、EN 优先级计算期望 ACC。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST)    ref_acc <= 0;
        else if (CLR) ref_acc <= 0;
        else if (EN)  ref_acc <= ref_acc + A * B;
    end

    // 检查器：每个上升沿后等 2 ns，让非阻塞赋值更新完毕。
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

        // 第一部分：随机运算，混合使能与清零。
        for (i = 0; i < 40; i = i + 1) begin
            @(negedge CLK);
            A   = $random(seed);
            B   = $random(seed);
            EN  = ($random(seed) % 4) != 0;      // 约四分之三的随机周期打开 EN。
            CLR = (i % 10 == 9);
        end

        // 第二部分：连续累加 16 次 +16384，期望为 262144。
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
