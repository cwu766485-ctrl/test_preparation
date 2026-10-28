`timescale 1ns/1ps
// 第21题测试：连续输入 150 个长度 1～16 位的字，最高位先送。
// 每一位上升沿后检查 GT/EQ/LT：比较对象是截至本拍已收到的两个前缀，而不只看最终整字。
// 交替覆盖随机输入、完全相等、仅最低位不同的情况；时钟周期为 2*CLK_T=20 ns。
module SerialComparator_tb;
    parameter CLK_T = 10;

    reg  CLK, NRST, FIRST, A, B;
    wire GT, EQ, LT;

    integer w, i, n, seed, errors, words, checks, log_fd;
    reg [15:0] a_w, b_w, a_pre, b_pre;

    SerialComparator U1 (.CLK(CLK), .NRST(NRST), .FIRST(FIRST), .A(A), .B(B),
                         .GT(GT), .EQ(EQ), .LT(LT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SerialComparator.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SerialComparator_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; words = 0; checks = 0; seed = 21;
        NRST = 0; FIRST = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (w = 0; w < 150; w = w + 1) begin
            n   = ($random(seed) & 15) + 1;
            a_w = $random(seed);
            case (w % 3)
                0: b_w = $random(seed);                 // 随机值
                1: b_w = a_w;                           // 两个输入相等
                2: b_w = a_w ^ 16'h0001;                // 仅最低位不同，检验最后一拍才决定大小
            endcase
            if (w == 0) begin n = 4; a_w = 16'd9; b_w = 16'd5; end   // 定向例：二进制 1001 大于 0101

            a_pre = 0; b_pre = 0;
            for (i = n - 1; i >= 0; i = i - 1) begin
                @(negedge CLK);
                A = a_w[i]; B = b_w[i]; FIRST = (i == n - 1);
                @(posedge CLK); #2;                     // Moore 输出在本位上升沿更新后采样
                a_pre = {a_pre[14:0], a_w[i]};          // 截至当前拍收到的高位前缀
                b_pre = {b_pre[14:0], b_w[i]};
                checks = checks + 1;
                if (GT !== (a_pre > b_pre) || EQ !== (a_pre == b_pre) || LT !== (a_pre < b_pre)) begin
                    errors = errors + 1;
                    $display ("FAIL word %0d bit %0d: A=%h B=%h prefix %h vs %h -> GT=%b EQ=%b LT=%b",
                              w, i, a_w, b_w, a_pre, b_pre, GT, EQ, LT);
                end
            end
            words = words + 1;
            $fdisplay(log_fd, "n=%2d A=%h B=%h -> GT=%b EQ=%b LT=%b", n, a_pre, b_pre, GT, EQ, LT);
        end

        $display ("==== DONE: %0d words, %0d bit checks, %0d errors ====", words, checks, errors);
        $fdisplay(log_fd, "==== DONE: %0d words, %0d bit checks, %0d errors ====", words, checks, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
