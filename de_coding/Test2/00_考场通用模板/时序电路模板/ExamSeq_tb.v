`timescale 1ns/1ps
// 自检测试平台：设计的运算或完成时序改变时，下面的参考答案和等待拍数也必须同步修改。
module ExamSeq_tb;
    parameter CLK_T = 10;             // CLK_T 是半周期，因此完整时钟周期为 20 ns。
    parameter NUM_VECTORS = 8;

    reg CLK, NRST, START;
    reg [15:0] A, B;
    reg [4:0] N;
    wire [15:0] RESULT;
    wire FLAG, DONE;
    reg [39:0] vectors [0:NUM_VECTORS-1]; // 每条向量共 40 位，依次存放 8 位 N、16 位 A、16 位 B；实际模块只使用 N 的低 5 位。
    integer i, n, k, seed, tests, errors, log_fd;

    ExamSeq U1 (.CLK(CLK), .NRST(NRST), .START(START),
                .A(A), .B(B), .N(N), .RESULT(RESULT),
                .FLAG(FLAG), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ExamSeq.sdf", U1);
`endif
`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ExamSeq_tb);
    end
`endif

    initial CLK = 0;
    always #CLK_T CLK = ~CLK;

    task run_case;
        input [15:0] a, b;
        input [4:0] nn;
        integer effective_n, cycles;
        reg [15:0] mask, expected_result;
        reg expected_flag;
        begin
            effective_n = (nn == 0 || nn > 16) ? 16 : nn;
            mask = (effective_n == 16) ? 16'hFFFF :
                   (16'hFFFF >> (16 - effective_n));

            // 修改点 TB-1：用独立的算术公式计算预期结果和标志，避免直接照搬设计内部逻辑。
            expected_result = (a ^ b) & mask;
            expected_flag = 1'b0;

            @(negedge CLK);
            A = a; B = b; N = nn; START = 1'b1;
            @(posedge CLK); #2;          // 此上升沿设计锁存 START、A、B、N；等待 2 ns 避开非阻塞赋值更新时刻。
            @(negedge CLK);
            A = ~a; B = ~b; N = 5'd1;  // 锁存后故意改变 A、B、N，检查运行过程是否错误地继续读取外部输入。
            START = (effective_n > 2); // 位数大于 2 时忙碌期间再拉高 START，检查设计是否忽略新请求。

            cycles = 0;
            while (DONE !== 1'b1 && cycles <= 18) begin
                @(posedge CLK); #2;
                cycles = cycles + 1;
                if (DONE !== 1'b1) begin
                    @(negedge CLK);
                    START = 1'b0;
                end
            end
            tests = tests + 1;
            // 修改点 TB-2：核对 DONE 出现的拍数、结果和 FLAG；=== 风格比较可检出 X/Z。
            if (DONE !== 1'b1 || cycles != effective_n ||
                RESULT !== expected_result || FLAG !== expected_flag) begin
                errors = errors + 1;
                $display("FAIL N=%0d A=%h B=%h: RESULT=%h FLAG=%b cycles=%0d; expected %h %b %0d",
                         nn, a, b, RESULT, FLAG, cycles,
                         expected_result, expected_flag, effective_n);
                $fdisplay(log_fd, "FAIL N=%0d A=%h B=%h", nn, a, b);
            end else
                $fdisplay(log_fd, "PASS N=%0d A=%h B=%h -> %h", nn, a, b, RESULT);

            @(negedge CLK); START = 1'b0;
            @(posedge CLK); #2;
            if (DONE !== 1'b0) begin
                errors = errors + 1;
                $display("FAIL: DONE must last one clock");
                $fdisplay(log_fd, "FAIL: DONE pulse width");
            end
        end
    endtask

    initial begin
        $readmemh("InputVector.txt", vectors);
        log_fd = $fopen("Check.txt", "w");
        tests = 0; errors = 0; seed = 42;
        NRST = 0; START = 0; A = 0; B = 0; N = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (i = 0; i < NUM_VECTORS; i = i + 1)
            run_case(vectors[i][31:16], vectors[i][15:0], vectors[i][36:32]);
        for (n = 1; n <= 16; n = n + 1)
            for (k = 0; k < 4; k = k + 1)
                run_case($random(seed), $random(seed), n);

        $display("==== DONE: %0d sequential cases, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d sequential cases, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
