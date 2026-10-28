`timescale 1ns/1ps
// ============================================================
// 测试平台：检查 Moore 型 101 序列检测器。
// 固定比特流从最高位起逐拍送入 DIN。
// 独立参考模型 hist 保存最近三位，据此计算 DET 应否为 1。
// 时钟周期为 2×CLK_T=20 ns；应与约束文件的时钟周期一致。
// ============================================================
module SeqDet101_tb;
    parameter CLK_T = 10;                 // CLK_T 是半周期 10 ns，因此完整周期是 20 ns。

    reg  CLK, NRST, DIN;
    wire DET;

    parameter N = 20;                     // 输入流包含 20 个比特。
    reg [N-1:0] stream = 20'b1011_0101_0010_1101_1010;   // 从最高位开始输入，便于按书写顺序阅读 101 模式。

    reg [2:0] hist;                       // 参考模型保留最近采样的三位。
    integer   i, errors, hits, log_fd;

    SeqDet101 U1 (.CLK(CLK), .NRST(NRST), .DIN(DIN), .DET(DET));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SeqDet101.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SeqDet101_tb);
    end
`endif

    // 产生时钟：每隔 CLK_T 翻转一次。
    initial begin
        CLK = 0;
        forever #CLK_T CLK = !CLK;
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        NRST = 0; DIN = 0; hist = 3'b000; errors = 0; hits = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;                                         // 在下降沿解除复位，避开采样上升沿附近。

        for (i = N-1; i >= 0; i = i - 1) begin
            @(negedge CLK) DIN = stream[i];               // 在下降沿切换 DIN，让它在下一上升沿前稳定。
            @(posedge CLK);                               // 此上升沿被测设计采样 DIN。
            hist = {hist[1:0], DIN};                      // 参考模型也收下同一位，并形成最新三位。
            #2;                                           // 等 2 ns，让寄存器输出和门级路径完成更新后再比较。
            if (DET !== (hist == 3'b101)) begin
                errors = errors + 1;
                $fdisplay(log_fd, "FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, hist == 3'b101);
                $display ("FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, hist == 3'b101);
            end else
                $fdisplay(log_fd, "PASS t=%0t DIN=%b last3=%b DET=%b", $time, DIN, hist, DET);
            if (DET) hits = hits + 1;
        end

        // 额外检查异步复位：无需等下个时钟，DET 就必须清零。
        @(negedge CLK); #3 NRST = 0; #1;
        if (DET !== 1'b0) begin errors = errors + 1; $display("FAIL: async reset"); end

        $display ("==== DONE: %0d detections, %0d errors ====", hits, errors);
        $fdisplay(log_fd, "==== DONE: %0d detections, %0d errors ====", hits, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
