`timescale 1ns/1ps
// ============================================================
// 测试平台：检查每拍是否符合反馈公式、是否意外进入全零状态、首次回到种子是否恰好经过 15 步，以及 15 个非零状态是否都出现。上升沿后等待 2 ns 采样，时钟周期 20 ns。
// ============================================================
module LFSR4_tb;
    parameter CLK_T = 10;

    reg        CLK, NRST, EN;
    wire [3:0] Q;
    reg  [3:0] prev, first;
    reg [15:0] seen;                    // 位图 seen 的第 v 位为 1，表示已经访问过状态 v
    integer    i, period, errors, log_fd;

    LFSR4 U1 (.CLK(CLK), .NRST(NRST), .EN(EN), .Q(Q));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_LFSR4.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, LFSR4_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; seen = 0; period = 0;
        NRST = 0; EN = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;
        if (Q !== 4'b0001) begin errors = errors + 1; $display("FAIL: reset value %b", Q); end
        first = Q; seen[Q] = 1'b1;
        EN = 1;

        for (i = 1; i <= 20; i = i + 1) begin
            prev = Q;
            @(posedge CLK); #2;
            $fdisplay(log_fd, "step %2d : Q = %b (%0d)", i, Q, Q);
            if (Q !== {prev[2:0], prev[3] ^ prev[2]}) begin
                errors = errors + 1; $display("FAIL step %0d: %b -> %b", i, prev, Q);
            end
            if (Q == 4'b0000) begin errors = errors + 1; $display("FAIL: reached 0000"); end
            if (Q == first && period == 0) period = i;     // 第一次回到初始种子时记录循环长度
            seen[Q] = 1'b1;
        end

        if (period != 15) begin errors = errors + 1; $display("FAIL: period = %0d", period); end
        if (seen != 16'hFFFE) begin errors = errors + 1; $display("FAIL: states seen = %b", seen); end

        $display ("==== DONE: period = %0d, %0d errors ====", period, errors);
        $fdisplay(log_fd, "==== DONE: period = %0d, %0d errors ====", period, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
