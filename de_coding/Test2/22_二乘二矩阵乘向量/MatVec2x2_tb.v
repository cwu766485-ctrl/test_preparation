`timescale 1ns/1ps
// 第22题测试：先输入单位矩阵、极值和混合符号，再输入随机矩阵与向量。
// 一次只在最初启动时给 START，之后每四拍连续送入下一组；OUT_STROBE 为 1 时依次核对 Y0/Y1。
// CLK 每 CLK_T 时间翻转，完整周期为 2*CLK_T=20 ns。
module MatVec2x2_tb;
    parameter CLK_T = 10;
    parameter N_OP  = 40;

    reg                CLK, NRST, START;
    reg  signed [7:0]  A, B;
    wire signed [16:0] Y0, Y1;
    wire               OUT_STROBE;

    integer m00 [0:N_OP-1], m01 [0:N_OP-1], m10 [0:N_OP-1], m11 [0:N_OP-1];
    integer x0  [0:N_OP-1], x1  [0:N_OP-1];
    integer k, seed, errors, n_res, log_fd, e0, e1;

    MatVec2x2 U1 (.CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B),
                  .Y0(Y0), .Y1(Y1), .OUT_STROBE(OUT_STROBE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_MatVec2x2.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, MatVec2x2_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 在每组结果有效时进行核对
    always @(posedge CLK) begin
        #2;
        if (NRST && OUT_STROBE) begin
            e0 = m00[n_res] * x0[n_res] + m01[n_res] * x1[n_res];
            e1 = m10[n_res] * x0[n_res] + m11[n_res] * x1[n_res];
            if ($signed(Y0) !== e0 || $signed(Y1) !== e1) begin
                errors = errors + 1;
                $display ("FAIL op %0d: Y0=%0d Y1=%0d (exp %0d %0d)", n_res, $signed(Y0), $signed(Y1), e0, e1);
                $fdisplay(log_fd, "FAIL op %0d: Y0=%0d Y1=%0d (exp %0d %0d)", n_res, $signed(Y0), $signed(Y1), e0, e1);
            end else
                $fdisplay(log_fd, "PASS op %0d: [%0d %0d; %0d %0d] x [%0d; %0d] = [%0d; %0d]", n_res,
                          m00[n_res], m01[n_res], m10[n_res], m11[n_res], x0[n_res], x1[n_res], $signed(Y0), $signed(Y1));
            n_res = n_res + 1;
        end
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n_res = 0; seed = 22;
        for (k = 0; k < N_OP; k = k + 1) begin
            m00[k] = $random(seed) % 128; m01[k] = $random(seed) % 128;
            m10[k] = $random(seed) % 128; m11[k] = $random(seed) % 128;
            x0[k]  = $random(seed) % 128; x1[k]  = $random(seed) % 128;
        end
        // 定向测试：单位矩阵、边界值、正负数混合
        m00[0] = 1;    m01[0] = 0;    m10[0] = 0;    m11[0] = 1;    x0[0] = 5;    x1[0] = -7;
        m00[1] = -128; m01[1] = -128; m10[1] = -128; m11[1] = -128; x0[1] = -128; x1[1] = -128;
        m00[2] = 127;  m01[2] = -128; m10[2] = -128; m11[2] = 127;  x0[2] = -128; x1[2] = 127;
        m00[3] = 2;    m01[3] = 3;    m10[3] = 4;    m11[3] = 5;    x0[3] = 10;   x1[3] = 1;

        NRST = 0; START = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (k = 0; k < N_OP; k = k + 1) begin
            @(negedge CLK); A = m00[k]; B = x0[k]; START = (k == 0);
            @(negedge CLK); A = m01[k]; B = x1[k]; START = 0;
            @(negedge CLK); A = m10[k]; B = x0[k];
            @(negedge CLK); A = m11[k]; B = x1[k];
        end
        repeat (3) @(posedge CLK);
        #3;

        if (n_res != N_OP) begin errors = errors + 1; $display("FAIL: %0d results for %0d operations", n_res, N_OP); end
        $display ("==== DONE: %0d operations, %0d errors ====", N_OP, errors);
        $fdisplay(log_fd, "==== DONE: %0d operations, %0d errors ====", N_OP, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
