`timescale 1ns/1ps
// ============================================================
// 测试平台：检查 4 位脉动进位加法器 Adder4。
// 从 InputVector.txt 读二进制测试向量；每行按 A 的 4 位、B 的 4 位、进位输入排列。
// 用独立的 A+B+CIN 算式计算 5 位答案，并把通过或失败记录到 Check.txt。
// 同一测试平台可用于行为级仿真及综合后带延时的门级仿真：
//     行为级：vcs -debug +v2k +define+VCS ./Adder4_tb.v ./Adder4.v ./FullAdder.v
//     门级：vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM ./Adder4_tb.v ./Syn_Adder4.v -f ./library.f
// ============================================================
module Adder4_tb;
    reg  [3:0] A, B;            // 测试平台驱动设计输入，故输入信号声明为 reg。
    reg        CIN;
    wire [3:0] S;               // 被测设计驱动输出，故输出信号声明为 wire。
    wire       COUT;

    reg  [8:0] vec [0:255];     // 一条向量共 9 位：{A[3:0], B[3:0], CIN}；最多预留 256 条。
    reg  [4:0] expected;
    integer    i, n, errors, log_fd;

    // 被测设计实例命名为 U1；SDF 延时标注及后续功耗流程都要引用此实例。
    Adder4 U1 (.A(A), .B(B), .CIN(CIN), .S(S), .COUT(COUT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_Adder4.sdf", U1);     // 只在门级仿真时把 SDF 中的门延时标注到 U1。
`endif

`ifdef VCS
    initial begin                                     // VCS 记录切换活动到 inter.vpd，供后续功耗分析使用。
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, Adder4_tb);
    end
`endif

    initial begin
        log_fd = $fopen("Check.txt", "w");
        for (i = 0; i < 256; i = i + 1) vec[i] = 9'bx;
        $readmemb("InputVector.txt", vec);            // 按二进制读取向量；文件中允许用下划线分组，也允许有双斜杠注释。
        n = 0; errors = 0;
        A = 0; B = 0; CIN = 0;
        #10;

        for (i = 0; i < 256 && vec[i] !== 9'bx; i = i + 1) begin
            {A, B, CIN} = vec[i];
            #10;                                      // 输入改变后等 10 ns 再比较，让组合逻辑及门级延时充分稳定。
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
