`timescale 1ns/1ps
// 第27题自检测试：从当前目录读取 InputVector.txt 中的定向输入，再对每种位宽测 8 组随机数。
// 每组先按 N 位掩码算出期望差值和借位，再启动设计并检查 DONE 出现的拍数。
// 运算期间故意更改 A/B/N 并再次置 START，验证设计使用已锁存的操作数；最后检查 DONE 仅持续一拍。
module SerialSubtractor_tb;
    parameter W = 16;
    parameter CLK_T = 10;                 // 完整时钟周期为 20 ns
    parameter NUM_VECTORS = 20;

    reg          CLK, NRST, START;
    reg  [W-1:0] A, B;
    reg  [4:0]   N;
    wire [W-1:0] DIFF;
    wire         BOUT, DONE;

    reg [39:0] vectors [0:NUM_VECTORS-1]; // 每个向量含 8 位 N、16 位 A、16 位 B
    integer i, n, k, seed, tests, errors, log_fd;

    SerialSubtractor U1 (
        .CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B), .N(N),
        .DIFF(DIFF), .BOUT(BOUT), .DONE(DONE)
    );

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SerialSubtractor.sdf", U1);
`endif
`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SerialSubtractor_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    task run_sub;
        input [W-1:0] a, b;
        input [4:0] nn;
        integer effective_n, cycles;
        reg [W-1:0] mask, a_low, b_low, expected_diff;
        reg expected_borrow;
        begin
            // 先用纯算术建立参考值；掩码只保留题目要求计算的低 N 位。
            effective_n = (nn == 0 || nn > W) ? W : nn;
            mask = (effective_n == W) ? {W{1'b1}} :
                   ({W{1'b1}} >> (W - effective_n));
            a_low = a & mask;
            b_low = b & mask;
            expected_diff = (a_low - b_low) & mask;
            expected_borrow = (a_low < b_low);

            @(negedge CLK);
            A = a; B = b; N = nn; START = 1'b1;
            @(posedge CLK); #2;              // 此上升沿采样 START 并锁存输入
            @(negedge CLK);
            START = (effective_n > 2);       // 故意在忙状态再次拉高 START，检查其被忽略
            A = ~a; B = ~b; N = 5'd1;       // 此处改变端口输入，设计仍须使用先前锁存值

            // START 已在前一个上升沿锁存；从下一上升沿起计数，直到 DONE 出现。
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
            // 同时核对完成信号、处理拍数、差值和最终借位；!== 能检出 X/Z。
            if (DONE !== 1'b1 || cycles != effective_n ||
                DIFF !== expected_diff || BOUT !== expected_borrow) begin
                errors = errors + 1;
                $display("FAIL N=%0d A=%h B=%h: DIFF=%h BOUT=%b cycles=%0d; expected %h %b %0d",
                         nn, a, b, DIFF, BOUT, cycles,
                         expected_diff, expected_borrow, effective_n);
                $fdisplay(log_fd,
                          "FAIL N=%0d A=%h B=%h: DIFF=%h BOUT=%b cycles=%0d; expected %h %b %0d",
                          nn, a, b, DIFF, BOUT, cycles,
                          expected_diff, expected_borrow, effective_n);
            end else begin
                $fdisplay(log_fd, "PASS N=%0d A=%h B=%h -> DIFF=%h BOUT=%b",
                          nn, a, b, DIFF, BOUT);
            end

            @(negedge CLK); START = 1'b0;
            @(posedge CLK); #2;
            if (DONE !== 1'b0) begin
                errors = errors + 1;
                $display("FAIL: DONE must be a one-clock pulse");
                $fdisplay(log_fd, "FAIL: DONE pulse width");
            end
        end
    endtask

    initial begin
        $readmemh("InputVector.txt", vectors);
        log_fd = $fopen("Check.txt", "w");
        tests = 0; errors = 0; seed = 27;
        NRST = 1'b0; START = 1'b0; A = 0; B = 0; N = 0;
        repeat (2) @(negedge CLK);
        NRST = 1'b1;

        // 定向向量覆盖 N=1、N=16 和发生借位的情况
        for (i = 0; i < NUM_VECTORS; i = i + 1)
            run_sub(vectors[i][31:16], vectors[i][15:0], vectors[i][36:32]);

        // 每种有效位宽再检查 8 组随机操作数
        for (n = 1; n <= W; n = n + 1)
            for (k = 0; k < 8; k = k + 1)
                run_sub($random(seed), $random(seed), n);

        $display("==== DONE: %0d subtractions, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d subtractions, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
