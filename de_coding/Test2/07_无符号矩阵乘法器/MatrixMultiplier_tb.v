`timescale 1ns/1ps
// ============================================================
// 测试平台：检查无符号矩阵乘法器。
// InputVector.txt 首行是说明，后续每行依次写 A1 B1 A0 B0，均为 0～255 的十进制数。
// 输入握手时序沿用 Module 5：
// 第一个下降沿送 A1/B1；仅首组同时拉高 START。
// 下一个下降沿送 A0/B0。
// 每组约五拍；OUT_STROBE 为 1 的周期表示 OUT 可被采样。
// 完整时钟周期为 2×CLK_T=20 ns，和 Module 5 约束一致。
// ============================================================
module MatrixMultiplier_tb;
    parameter CLK_T = 10;
    parameter N     = 32;

    reg         CLK, NRST, START;
    reg  [7:0]  A, B;                    // A、B 均按无符号 8 位使用。
    wire [16:0] OUT;
    wire        OUT_STROBE;

    integer a1 [0:N-1], b1 [0:N-1], a0 [0:N-1], b0 [0:N-1];
    integer n_vec, n_res, i, r, fd, log_fd, errors, expected;
    reg [8*256-1:0] header;

    MatrixMultiplier U1 (.CLK(CLK), .NRST(NRST), .START(START),
                         .A(A), .B(B), .OUT(OUT), .OUT_STROBE(OUT_STROBE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_MatrixMultiplier.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, MatrixMultiplier_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 每个上升沿后等 2 ns，若 OUT_STROBE 有效就把 OUT 与独立算式比较。
    always @(posedge CLK) begin
        #2;
        if (NRST && OUT_STROBE) begin
            expected = a1[n_res]*b1[n_res] + a0[n_res]*b0[n_res];
            if (OUT !== expected[16:0]) begin
                errors = errors + 1;
                $display ("FAIL vector %0d: OUT=%0d expected %0d", n_res, OUT, expected);
                $fdisplay(log_fd, "FAIL vector %0d: OUT=%0d expected %0d", n_res, OUT, expected);
            end else begin
                $display ("PASS vector %0d: %0d*%0d + %0d*%0d = %0d", n_res, a1[n_res], b1[n_res], a0[n_res], b0[n_res], OUT);
                $fdisplay(log_fd, "PASS vector %0d: %0d*%0d + %0d*%0d = %0d", n_res, a1[n_res], b1[n_res], a0[n_res], b0[n_res], OUT);
            end
            n_res = n_res + 1;
        end
    end

    initial begin
        // 读取测试向量。
        fd = $fopen("InputVector.txt", "r");
        if (fd == 0) begin $display("FAIL: InputVector.txt not found"); $finish; end
        r = $fgets(header, fd);                      // 跳过第一行文字说明。
        n_vec = 0;
        while (!$feof(fd) && n_vec < N) begin
            r = $fscanf(fd, "%d %d %d %d\n", a1[n_vec], b1[n_vec], a0[n_vec], b0[n_vec]);
            if (r == 4) n_vec = n_vec + 1;
        end
        $fclose(fd);
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n_res = 0;

        // 先拉低 NRST，清空状态机和数据寄存器。
        NRST = 0; START = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        // 逐组施加向量。
        for (i = 0; i < n_vec; i = i + 1) begin
            @(negedge CLK);
            A = a1[i]; B = b1[i]; START = (i == 0);
            @(posedge CLK);                          // 此上升沿 en1 锁存第一项 A1×B1。
            @(negedge CLK);
            A = a0[i]; B = b0[i]; START = 0;
            repeat (4) @(posedge CLK);               // 继续运行四个上升沿，直到 en3 将结果写入 OUT。
        end
        repeat (2) @(posedge CLK);
        #3;

        if (n_res != n_vec) begin errors = errors + 1; $display("FAIL: got %0d results for %0d vectors", n_res, n_vec); end
        $display ("==== DONE: %0d vectors, %0d errors ====", n_vec, errors);
        $fdisplay(log_fd, "==== DONE: %0d vectors, %0d errors ====", n_vec, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
