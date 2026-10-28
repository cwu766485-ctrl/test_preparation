`timescale 1ns/1ps
// 第19题测试：连续送入 120 个字，最低位先送；前四组为定向案例，之后随机。
// 每个字长度为 1～16 位；在下降沿改变 A、B，待组合逻辑稳定后、上升沿前采样 S/CO。
// 把逐位收集的 S 与算术参考结果的低 n 位比较，并核对最后一位的 CO。
// CLK 每 CLK_T 时间翻转一次，完整周期为 2*CLK_T=20 ns。
module BitSerialAddSub_tb;
    parameter CLK_T = 10;

    reg  CLK, NRST, FIRST, SUB, A, B;
    wire S, CO;

    integer w, i, n, seed, errors, words, log_fd;
    reg [15:0] a_w, b_w, s_w, exp_s;
    reg [16:0] full;
    reg        exp_co, last_co;

    BitSerialAddSub U1 (.CLK(CLK), .NRST(NRST), .FIRST(FIRST), .SUB(SUB),
                        .A(A), .B(B), .S(S), .CO(CO));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_BitSerialAddSub.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, BitSerialAddSub_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; words = 0; seed = 19;
        NRST = 0; FIRST = 0; SUB = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (w = 0; w < 120; w = w + 1) begin
            // 先测试已知答案，再进行随机测试
            if (w == 0)      begin a_w = 16'd5;  b_w = 16'd3;  n = 4;  SUB = 0; end   // 加法例：5+3=8
            else if (w == 1) begin a_w = 16'd5;  b_w = 16'd3;  n = 4;  SUB = 1; end   // 无借位减法例：5-3=2
            else if (w == 2) begin a_w = 16'd3;  b_w = 16'd5;  n = 4;  SUB = 1; end   // 借位例：3-5 在 4 位中为 1110，最终有借位
            else if (w == 3) begin a_w = 16'hFFFF; b_w = 16'd1; n = 16; SUB = 0; end  // 加法溢出，末位进位 CO=1
            else begin
                a_w = $random(seed); b_w = $random(seed);
                n   = ($random(seed) & 15) + 1;
                SUB = $random(seed);
            end
            s_w = 0;
            for (i = 0; i < n; i = i + 1) begin
                @(negedge CLK);                    // 在下降沿送入下一对输入位
                A = a_w[i]; B = b_w[i]; FIRST = (i == 0);
                #(CLK_T/2);                        // 组合输出在上升沿之前稳定，此时读取
                s_w[i]  = S;
                last_co = CO;
            end
            // 计算独立的期望结果
            if (SUB) full = {1'b0, a_w} + {1'b0, ~b_w} + 17'd1;
            else     full = {1'b0, a_w} + {1'b0, b_w};
            exp_s  = full[15:0] & ((n == 16) ? 16'hFFFF : ((16'd1 << n) - 1));
            // 只取低 n 位运算后第 n−1 位的进位
            if (SUB) full = (a_w & ((17'd1 << n) - 1)) + ((~b_w) & ((17'd1 << n) - 1)) + 1;
            else     full = (a_w & ((17'd1 << n) - 1)) + (b_w  & ((17'd1 << n) - 1));
            exp_co = full[n];
            words  = words + 1;
            if (s_w !== exp_s || last_co !== exp_co) begin
                errors = errors + 1;
                $display ("FAIL n=%2d %s A=%h B=%h -> S=%h CO=%b (exp %h %b)", n, SUB ? "SUB" : "ADD", a_w, b_w, s_w, last_co, exp_s, exp_co);
                $fdisplay(log_fd, "FAIL n=%2d %s A=%h B=%h -> S=%h CO=%b (exp %h %b)", n, SUB ? "SUB" : "ADD", a_w, b_w, s_w, last_co, exp_s, exp_co);
            end else
                $fdisplay(log_fd, "PASS n=%2d %s A=%h B=%h -> S=%h CO=%b", n, SUB ? "SUB" : "ADD", a_w, b_w, s_w, last_co);
        end

        $display ("==== DONE: %0d words, %0d errors ====", words, errors);
        $fdisplay(log_fd, "==== DONE: %0d words, %0d errors ====", words, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
