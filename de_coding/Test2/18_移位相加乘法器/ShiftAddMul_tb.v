`timescale 1ns/1ps
// ============================================================
// 测试平台：检查 0、1、255、二的幂等边界值和 300 组随机乘法；定义 FULL 宏可穷举 8 位 A、B 的全部组合。每题将 P 与 a×b 比较，并检查 DONE 是否在 START 后 W+1 个时钟周期到来。输入在下降沿改变。
// ============================================================
module ShiftAddMul_tb;
    parameter CLK_T = 10;
    parameter W     = 8;

    reg              CLK, NRST, START;
    reg  [W-1:0]     A, B;
    wire [2*W-1:0]   P;
    wire             DONE;

    integer i, j, seed, errors, tests, cycles, log_fd;
    reg [2*W-1:0] expected;

    ShiftAddMul U1 (.CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B), .P(P), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ShiftAddMul.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ShiftAddMul_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    task run_mul(input [W-1:0] a, input [W-1:0] b);
        begin
            @(negedge CLK);
            A = a; B = b; START = 1'b1;
            @(negedge CLK);
            START = 1'b0; A = ~a; B = ~b;          // 启动后故意改动外部输入，验证内部已保存操作数
            cycles = 1;
            while (DONE !== 1'b1) begin
                @(negedge CLK);
                cycles = cycles + 1;
                if (cycles > 3 * W) begin
                    $display("FAIL: no DONE"); errors = errors + 1; disable run_mul;
                end
            end
            expected = a * b;
            tests = tests + 1;
            if (P !== expected || cycles != W + 1) begin
                errors = errors + 1;
                $display ("FAIL %0d * %0d -> P=%0d (exp %0d), DONE after %0d clk", a, b, P, expected, cycles);
                $fdisplay(log_fd, "FAIL %0d * %0d -> P=%0d (exp %0d)", a, b, P, expected);
            end else if (tests <= 400)
                $fdisplay(log_fd, "PASS %0d * %0d = %0d", a, b, P);
        end
    endtask

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; tests = 0; seed = 5;
        NRST = 0; START = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        run_mul(0, 0);     run_mul(0, 255);   run_mul(255, 0);
        run_mul(1, 1);     run_mul(1, 255);   run_mul(255, 1);
        run_mul(255, 255); run_mul(128, 2);   run_mul(16, 16);
        run_mul(13, 11);   run_mul(170, 85);  run_mul(200, 3);
`ifdef FULL
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                run_mul(i, j);
`else
        for (i = 0; i < 300; i = i + 1)
            run_mul($random(seed), $random(seed));
`endif

        $display ("==== DONE: %0d multiplications, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d multiplications, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
