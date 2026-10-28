`timescale 1ns/1ps
// ============================================================
// 测试平台：检查 Mealy 型 101 检测器。
// 与第 2 题 Moore 型测试平台的关键区别：
// 最后一个 1 仍在 DIN 上、尚未到上升沿时，就检查 DET。
// 因为 Mealy 输出对当前输入的变化立即作出组合响应。
// 时钟周期为 2×CLK_T=20 ns。
// ============================================================
module SeqDet101_Mealy_tb;
    parameter CLK_T = 10;

    reg  CLK, NRST, DIN;
    wire DET;

    parameter N = 20;
    reg [N-1:0] stream = 20'b1011_0101_0010_1101_1010;   // 使用与第 2 题相同的输入流，方便对照检测时刻。

    reg [1:0] prev2;                 // 保存当前位之前收到的最近两位；连同 DIN 判断是否出现 101。
    integer   i, errors, hits, log_fd;

    SeqDet101_Mealy U1 (.CLK(CLK), .NRST(NRST), .DIN(DIN), .DET(DET));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SeqDet101_Mealy.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SeqDet101_Mealy_tb);
    end
`endif

    initial begin
        CLK = 0;
        forever #CLK_T CLK = !CLK;
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        NRST = 0; DIN = 0; prev2 = 2'b00; errors = 0; hits = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (i = N-1; i >= 0; i = i - 1) begin
            @(negedge CLK) DIN = stream[i];        // 在下降沿送入新位，保证到上升沿有建立时间。
            #(CLK_T/2);                            // 再等半个 CLK_T，在下一上升沿之前检查 DET 是否已有效。
            if (DET !== ({prev2, DIN} == 3'b101)) begin
                errors = errors + 1;
                $display ("FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, {prev2, DIN} == 3'b101);
                $fdisplay(log_fd, "FAIL t=%0t DIN=%b DET=%b expected %b", $time, DIN, DET, {prev2, DIN} == 3'b101);
            end else
                $fdisplay(log_fd, "PASS t=%0t last3=%b DET=%b", $time, {prev2, DIN}, DET);
            if (DET) hits = hits + 1;
            @(posedge CLK);
            prev2 = {prev2[0], DIN};               // 当前位随后纳入参考历史，供下一位判断。
        end

        @(negedge CLK); DIN = 1; #3 NRST = 0; #1;
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
