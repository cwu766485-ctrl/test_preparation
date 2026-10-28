`timescale 1ns/1ps
// ============================================================
// 改错题 6 的测试平台：按最高位优先依次送入固定比特流，每拍一个 DIN。hist 保存最近 3 位，预期 DET=(hist==101)。DIN 在下降沿改变，DUT 在上升沿采样，2 ns 后比对；末尾检查异步复位。
// ============================================================
module SeqDet101_tb;
    parameter CLK_T = 10;                 // 半周期 10 ns，所以时钟完整周期为 20 ns

    reg  CLK, NRST, DIN;
    wire DET;

    parameter N = 20;                     // 输入比特流的长度
    reg [N-1:0] stream = 20'b1011_0101_0010_1101_1010;   // 从最高位开始逐位发送

    reg [2:0] hist;                       // 参考模型记录最近收到的 3 位，用来判断是否出现 101
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

    // 时钟发生器：每隔 CLK_T 翻转一次电平。
    initial begin
        CLK = 0;
        forever #CLK_T CLK = !CLK;
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        NRST = 0; DIN = 0; hist = 3'b000; errors = 0; hits = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;                                         // 在非采样沿释放复位，避免与时钟上升沿竞争

        for (i = N-1; i >= 0; i = i - 1) begin
            @(negedge CLK) DIN = stream[i];               // 在下降沿改变 DIN，为下一个上升沿留出稳定时间
            @(posedge CLK);                               // 被测模块在这个上升沿采样 DIN
            hist = {hist[1:0], DIN};                      // 参考模型同拍记录 DIN，形成新的最近三位
            #2;                                           // 等待触发器输出和门延迟稳定后再检查
            if (DET !== (hist == 3'b101)) begin
                errors = errors + 1;
                $fdisplay(log_fd, "FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, hist == 3'b101);
                $display ("FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, hist == 3'b101);
            end else
                $fdisplay(log_fd, "PASS t=%0t DIN=%b last3=%b DET=%b", $time, DIN, hist, DET);
            if (DET) hits = hits + 1;
        end

        // 异步复位检查：不用等待下一个时钟沿，DET 就必须清零。
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
