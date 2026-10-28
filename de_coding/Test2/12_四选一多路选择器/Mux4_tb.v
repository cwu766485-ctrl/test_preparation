`timescale 1ns/1ps
// ============================================================
// 测试平台：生成 64 组固定随机种子的数据，每组依次测试 4 种 SEL，共检查 256 次。expected 根据 SEL 独立选取对应输入，等待 5 ns 后比较。
// ============================================================
module Mux4_tb;
    reg  [3:0] D0, D1, D2, D3;
    reg  [1:0] SEL;
    wire [3:0] Y;
    reg  [3:0] expected;
    integer    k, s, seed, n, errors, log_fd;

    Mux4 U1 (.D0(D0), .D1(D1), .D2(D2), .D3(D3), .SEL(SEL), .Y(Y));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_Mux4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, Mux4_tb);
    end
`endif

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n = 0; seed = 1;
        for (k = 0; k < 64; k = k + 1) begin
            D0 = $random(seed); D1 = $random(seed); D2 = $random(seed); D3 = $random(seed);
            for (s = 0; s < 4; s = s + 1) begin
                SEL = s;
                #5;
                case (s)
                    0: expected = D0;
                    1: expected = D1;
                    2: expected = D2;
                    3: expected = D3;
                endcase
                if (Y !== expected) begin
                    errors = errors + 1;
                    $display ("FAIL SEL=%b Y=%h expected %h", SEL, Y, expected);
                    $fdisplay(log_fd, "FAIL SEL=%b Y=%h expected %h", SEL, Y, expected);
                end
                n = n + 1;
                #5;
            end
        end
        $display ("==== DONE: %0d checks, %0d errors ====", n, errors);
        $fdisplay(log_fd, "==== DONE: %0d checks, %0d errors ====", n, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
