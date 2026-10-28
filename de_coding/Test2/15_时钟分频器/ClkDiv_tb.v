`timescale 1ns/1ps
// ============================================================
// 测试平台：输入时钟周期 20 ns。分别记录 DIV4、DIV5 的上升沿与下降沿，计算完整周期和高电平持续时间；期望分别为 80/40 ns、100/50 ns。允许 1 ns 误差，以兼容门级传播延迟。
// ============================================================
module ClkDiv_tb;
    parameter CLK_T = 10;                      // 这里是半周期 10 ns，因此完整输入时钟周期为 20 ns
    parameter T     = 2 * CLK_T;

    reg  CLK, NRST;
    wire DIV4, DIV5;

    realtime r4, f4, r5, f5;                   // 分别保存上一次上升沿和下降沿时间，以计算周期及高电平时间
    real     per4, hi4, per5, hi5;
    integer  n4, n5, errors, log_fd;

    ClkDiv U1 (.CLK(CLK), .NRST(NRST), .DIV4(DIV4), .DIV5(DIV5));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ClkDiv.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ClkDiv_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    function ok(input real got, input real exp_v);
        ok = (got > exp_v - 1.0) && (got < exp_v + 1.0);
    endfunction

    // 测量 DIV4：相邻上升沿之差是周期，上升到下降的间隔是高电平时间。
    always @(posedge DIV4) if (NRST) begin
        if (n4 > 0) begin
            per4 = $realtime - r4;
            if (!ok(per4, 4*T)) begin errors = errors + 1; $display("FAIL DIV4 period %0.2f", per4); end
        end
        r4 = $realtime; n4 = n4 + 1;
    end
    always @(negedge DIV4) if (NRST && n4 > 0) begin
        hi4 = $realtime - r4;
        if (!ok(hi4, 2*T)) begin errors = errors + 1; $display("FAIL DIV4 high %0.2f", hi4); end
        $fdisplay(log_fd, "DIV4 high = %0.1f ns, period = %0.1f ns", hi4, per4);
    end

    // 测量 DIV5：相邻上升沿之差是周期，上升到下降的间隔是高电平时间。
    always @(posedge DIV5) if (NRST) begin
        if (n5 > 0) begin
            per5 = $realtime - r5;
            if (!ok(per5, 5*T)) begin errors = errors + 1; $display("FAIL DIV5 period %0.2f", per5); end
        end
        r5 = $realtime; n5 = n5 + 1;
    end
    always @(negedge DIV5) if (NRST && n5 > 0) begin
        hi5 = $realtime - r5;
        if (!ok(hi5, 2.5*T)) begin errors = errors + 1; $display("FAIL DIV5 high %0.2f", hi5); end
        $fdisplay(log_fd, "DIV5 high = %0.1f ns, period = %0.1f ns", hi5, per5);
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n4 = 0; n5 = 0; per4 = 0; per5 = 0;
        NRST = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;
        repeat (60) @(posedge CLK);              // 运行 60 个输入时钟周期，足够观察约 15 个四分频周期和 12 个五分频周期
        if (n4 < 10 || n5 < 10) begin errors = errors + 1; $display("FAIL: too few edges"); end
        $display ("==== DONE: DIV4 period %0.1f ns high %0.1f ns | DIV5 period %0.1f ns high %0.1f ns | %0d errors ====",
                  per4, hi4, per5, hi5, errors);
        $fdisplay(log_fd, "==== DONE: %0d errors ====", errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
