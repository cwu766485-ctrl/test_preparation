`timescale 1ns/1ps
// ============================================================
// 改错题 3 的测试平台：从 InputVector.txt 读入每行的 4 位 A、4 位 B 和 1 位 CIN，计算 A+B+CIN，再比对 {COUT,S}。检查结果写入 Check.txt；同一测试平台可用于行为仿真和带 SDF 的门级仿真。
// ============================================================
module Adder4_tb;
    reg  [3:0] A, B;            // 测试平台主动驱动 DUT 输入，因此声明为 reg
    reg        CIN;
    wire [3:0] S;               // 由 DUT 驱动的输出，在测试平台中声明为 wire
    wire       COUT;

    reg  [8:0] vec [0:255];     // 一条向量按顺序包含 4 位 A、4 位 B 和 1 位 CIN
    reg  [4:0] expected;
    integer    i, n, errors, log_fd;

    // 被测模块实例名保持 U1，SDF 标注与功耗流程会引用它。
    Adder4 U1 (.A(A), .B(B), .CIN(CIN), .S(S), .COUT(COUT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_Adder4.sdf", U1);     // 仅门级仿真启用，用 SDF 注入门延迟
`endif

`ifdef VCS
    initial begin                                     // 记录翻转活动供后续功耗分析使用
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, Adder4_tb);
    end
`endif

    initial begin
        log_fd = $fopen("Check.txt", "w");
        for (i = 0; i < 256; i = i + 1) vec[i] = 9'bx;
        $readmemb("InputVector.txt", vec);            // 以二进制读入向量；下划线可分组，文件也允许行注释
        n = 0; errors = 0;
        A = 0; B = 0; CIN = 0;
        #10;

        for (i = 0; i < 256 && vec[i] !== 9'bx; i = i + 1) begin
            {A, B, CIN} = vec[i];
            #10;                                      // 等待 10 ns 使组合结果稳定，再与参考值比较
            expected = A + B + CIN;
            if ({COUT, S} !== expected) begin
                errors = errors + 1;
                $display ("FAIL t=%0t A=%0d B=%0d CIN=%b -> COUT=%b S=%0d (expected %0d)", $time, A, B, CIN, COUT, S, expected);
                $fdisplay(log_fd, "FAIL t=%0t A=%0d B=%0d CIN=%b -> COUT=%b S=%0d (expected %0d)", $time, A, B, CIN, COUT, S, expected);
            end else begin
                $display ("PASS t=%0t A=%0d B=%0d CIN=%b -> COUT=%b S=%0d", $time, A, B, CIN, COUT, S);
                $fdisplay(log_fd, "PASS t=%0t A=%0d B=%0d CIN=%b -> COUT=%b S=%0d", $time, A, B, CIN, COUT, S);
            end
            n = n + 1;
        end

        $display ("==== DONE: %0d vectors, %0d errors ====", n, errors);
        $fdisplay(log_fd, "==== DONE: %0d vectors, %0d errors ====", n, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
