`timescale 1ns/1ps
// ============================================================
// 测试平台：先跑边界样例，再对 N=1 到 16 的每个位宽各跑 8 组随机输入。期望值先用掩码截取低 N 位，再独立计算加法、结果位和进位；还检查 DONE 的时序与忙时 START 被忽略。输入在下降沿改变，避免与采样上升沿竞争。
// ============================================================
module SerialAdder_tb;
    parameter CLK_T = 10;
    parameter W     = 16;

    reg          CLK, NRST, START;
    reg  [W-1:0] A, B;
    reg  [4:0]   N;
    wire [W-1:0] SUM;
    wire         COUT, DONE;

    integer      errors, tests, n, k, seed, log_fd, cycles;
    reg  [W:0]   full;
    reg  [W-1:0] mask, exp_sum;
    reg          exp_c;

    SerialAdder U1 (.CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B), .N(N),
                    .SUM(SUM), .COUT(COUT), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SerialAdder.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SerialAdder_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 执行一组加法测试：启动、等待完成、计算独立期望值并比对。
    task run_add(input [W-1:0] a, input [W-1:0] b, input [4:0] nn);
        begin
            @(negedge CLK);                        // 在下降沿改变输入，避免与设计的上升沿采样竞争
            A = a; B = b; N = nn; START = 1'b1;
            @(negedge CLK);
            START = 1'b0;
            A = ~a;                                // 启动后故意改动外部 A，验证设计已锁存原始输入
            B = ~b;
            START = (nn > 2);                      // 忙时再次拉高 START，验证设计不会重新启动
            cycles = 1;
            while (DONE !== 1'b1) begin
                @(negedge CLK);
                START  = 1'b0;
                cycles = cycles + 1;
                if (cycles > 40) begin
                    $display("FAIL: no DONE for n=%0d", nn);
                    errors = errors + 1;
                    disable run_add;
                end
            end
            // 现在位于 DONE 有效那一拍的下降沿，可稳定读取结果。
            mask    = (nn >= W) ? {W{1'b1}} : ((1 << nn) - 1);
            full    = (a & mask) + (b & mask);
            exp_sum = full[W-1:0] & mask;
            exp_c   = full[nn];
            tests   = tests + 1;
            if (SUM !== exp_sum || COUT !== exp_c || cycles != nn + 1) begin
                errors = errors + 1;
                $display ("FAIL n=%2d A=%h B=%h -> SUM=%h COUT=%b (exp %h %b), DONE after %0d clk (exp %0d)",
                          nn, a, b, SUM, COUT, exp_sum, exp_c, cycles, nn + 1);
                $fdisplay(log_fd, "FAIL n=%2d A=%h B=%h -> SUM=%h COUT=%b (exp %h %b)", nn, a, b, SUM, COUT, exp_sum, exp_c);
            end else
                $fdisplay(log_fd, "PASS n=%2d A=%h B=%h -> SUM=%h COUT=%b", nn, a, b, SUM, COUT);
        end
    endtask

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; tests = 0; seed = 11;
        NRST = 0; START = 0; A = 0; B = 0; N = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        // 先测专门设计的边界和进位样例。
        run_add(16'd5,     16'd3,     5'd4);    // 5+3=8；对应学长报告中的基本样例
        run_add(16'd9,     16'd8,     5'd4);    // 4 位相加得到 17，低 4 位是 1，向第 5 位进位
        run_add(16'hFFFF,  16'h0001,  5'd16);   // 16 位全 1 加 1 后低位全零，产生进位
        run_add(16'hFFFF,  16'hFFFF,  5'd16);   // 两个 16 位全 1 相加，低位为 FFFE，产生进位
        run_add(16'h1,     16'h1,     5'd1);    // 最小位宽 1 位：1+1 的结果位为 0，进位为 1
        run_add(16'hABCD,  16'h1234,  5'd8);    // 只取低 8 位相加：CD+34=101，结果 01，进位 1

        // 逐一覆盖每种位宽，再对每种位宽测随机操作数。
        for (n = 1; n <= W; n = n + 1)
            for (k = 0; k < 8; k = k + 1)
                run_add($random(seed), $random(seed), n);

        $display ("==== DONE: %0d additions, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d additions, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
