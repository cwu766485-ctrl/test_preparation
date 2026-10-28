`timescale 1ns/1ps
// ============================================================
// 测试平台：穷举 A、B 各 0 到 15 的 256 种组合。输入稳定 5 ns 后，分别对照数学比较关系检查 GT、EQ、LT，结果写入 Check.txt。
// ============================================================
module Comparator4_tb;
    reg  [3:0] A, B;
    wire       GT, EQ, LT;
    integer    a, b, n, errors, log_fd;

    Comparator4 U1 (.A(A), .B(B), .GT(GT), .EQ(EQ), .LT(LT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_Comparator4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, Comparator4_tb);
    end
`endif

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n = 0;
        for (a = 0; a < 16; a = a + 1)
            for (b = 0; b < 16; b = b + 1) begin
                A = a; B = b;
                #5;
                if (GT !== (a > b) || EQ !== (a == b) || LT !== (a < b)) begin
                    errors = errors + 1;
                    $display ("FAIL A=%0d B=%0d -> GT=%b EQ=%b LT=%b", A, B, GT, EQ, LT);
                    $fdisplay(log_fd, "FAIL A=%0d B=%0d -> GT=%b EQ=%b LT=%b", A, B, GT, EQ, LT);
                end
                n = n + 1;
                #5;
            end
        $display ("==== DONE: %0d combinations, %0d errors ====", n, errors);
        $fdisplay(log_fd, "==== DONE: %0d combinations, %0d errors ====", n, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
