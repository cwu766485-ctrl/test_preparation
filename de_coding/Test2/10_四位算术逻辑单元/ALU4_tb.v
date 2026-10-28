`timescale 1ns/1ps
// ============================================================
// 测试平台：穷举 4 种 OP、16 种 A 和 16 种 B，共 1024 组。每次改变输入后等待 5 ns，再用独立计算的 exp_cy 检查进位、结果和零标志；错误写入 Check.txt。
// ============================================================
module ALU4_tb;
    reg  [3:0] A, B;
    reg  [1:0] OP;
    wire [3:0] Y;
    wire       C, Z;

    reg  [4:0] exp_cy;                 // 参考结果由高位 C 和低 4 位 Y 拼接
    integer    op, a, b, n, errors, log_fd;

    ALU4 U1 (.A(A), .B(B), .OP(OP), .Y(Y), .C(C), .Z(Z));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ALU4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ALU4_tb);
    end
`endif

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n = 0;
        for (op = 0; op < 4; op = op + 1)
            for (a = 0; a < 16; a = a + 1)
                for (b = 0; b < 16; b = b + 1) begin
                    OP = op; A = a; B = b;
                    #5;                                   // 等待组合逻辑传播稳定后再采样输出
                    case (op)
                        0: exp_cy = {1'b0, A} + {1'b0, B};
                        1: exp_cy = {1'b0, A} - {1'b0, B};
                        2: exp_cy = {1'b0, A & B};
                        3: exp_cy = {1'b0, A | B};
                    endcase
                    if ({C, Y} !== exp_cy || Z !== (exp_cy[3:0] == 0)) begin
                        errors = errors + 1;
                        $display ("FAIL OP=%b A=%0d B=%0d -> C=%b Y=%0d Z=%b (expected C=%b Y=%0d)", OP, A, B, C, Y, Z, exp_cy[4], exp_cy[3:0]);
                        $fdisplay(log_fd, "FAIL OP=%b A=%0d B=%0d -> C=%b Y=%0d Z=%b", OP, A, B, C, Y, Z);
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
