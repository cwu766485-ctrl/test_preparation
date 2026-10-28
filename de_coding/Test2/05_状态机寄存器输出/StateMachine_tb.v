`timescale 1ns/1ps
// ============================================================
// 测试平台：验证带寄存器输出的状态机。
// 按固定表格逐拍驱动 start、rst、A、B、CIN。
// 参考模型同时模拟状态转移与全加器，并把输出延后一拍。
// 毛刺监视器统计在上升沿附近以外发生的 S/COUT 跳变。
// 完整时钟周期 2×CLK_T=100 ns，应与 Module 4 约束一致。
// ============================================================
module StateMachine_tb;
    parameter CLK_T = 50;
    parameter N     = 32;

    reg  CLK, NRST, start, rst, CIN, A, B;
    wire S, COUT;

    // 独立参考模型用到的状态和结果寄存器。
    reg  [1:0] ref_state;
    reg        exp_S, exp_COUT;
    wire       sum   = A ^ B ^ CIN;
    wire       carry = (A & B) | (CIN & (A ^ B));

    reg  [4:0] ctrl [0:N-1];          // 每拍控制字依次为 {start,rst,B,A,CIN}。
    integer    i, errors, glitches, log_fd;
    realtime   t_edge;

    StateMachine U1 (.CLK(CLK), .NRST(NRST), .start(start), .rst(rst),
                     .CIN(CIN), .A(A), .B(B), .S(S), .COUT(COUT));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_StateMachine.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, StateMachine_tb);
    end
`endif

    initial begin
        CLK = 0;
        forever #CLK_T CLK = !CLK;
    end

    // 参考状态机以及延迟一拍的预期输出。
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            ref_state <= 2'b00; exp_S <= 0; exp_COUT <= 0;
        end else begin
            exp_S    <= (ref_state == 2'b01 || ref_state == 2'b11) ? sum   : 1'b0;
            exp_COUT <= (ref_state == 2'b10 || ref_state == 2'b11) ? carry : 1'b0;
            case (ref_state)
                2'b00: ref_state <= start ? 2'b01 : 2'b00;
                2'b01: ref_state <= rst ? 2'b00 : 2'b10;
                2'b10: ref_state <= rst ? 2'b00 : 2'b11;
                2'b11: ref_state <= rst ? 2'b00 : 2'b01;
            endcase
        end
    end

    // 正常情况下，输出仅允许在上升沿之后 2 ns 窗口内变化。
    always @(posedge CLK) t_edge = $realtime;
    always @(S or COUT)
        if (NRST && ($realtime - t_edge > 2.0)) glitches = glitches + 1;

    // 每个上升沿后等待 2 ns，再检查输出和预期值。
    always @(posedge CLK) begin
        #2;
        if (NRST) begin
            if (S !== exp_S || COUT !== exp_COUT) begin
                errors = errors + 1;
                $display ("FAIL t=%0t S=%b COUT=%b expected %b %b", $time, S, COUT, exp_S, exp_COUT);
                $fdisplay(log_fd, "FAIL t=%0t S=%b COUT=%b expected %b %b", $time, S, COUT, exp_S, exp_COUT);
            end else
                $fdisplay(log_fd, "PASS t=%0t state(ref)=%0d S=%b COUT=%b", $time, ref_state, S, COUT);
        end
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; glitches = 0; t_edge = 0;
        // 生成刺激表：第 1 拍和第 14 拍启动，第 12 拍与第 25 拍同步复位，
        // A/B/CIN 通过步长为 5 的序列遍历 8 种组合。
        for (i = 0; i < N; i = i + 1) begin
            ctrl[i][4]   = (i == 1  || i == 14);   // start 在这两拍置 1。
            ctrl[i][3]   = (i == 12 || i == 25);   // rst 在这两拍置 1。
            ctrl[i][2:0] = (i * 5) % 8;            // 低三位编码 {B,A,CIN}。
        end

        NRST = 0; {start, rst, B, A, CIN} = 5'b0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (i = 0; i < N; i = i + 1) begin
            @(negedge CLK);
            {start, rst, B, A, CIN} = ctrl[i];
        end
        @(negedge CLK); {start, rst} = 2'b00;
        @(negedge CLK);                     // 再等一拍，以便最后一组输入的寄存器输出出现。

        #3 NRST = 0; #1;                    // 再次拉低异步复位，检查输出寄存器立即清零。
        if (S !== 0 || COUT !== 0) begin errors = errors + 1; $display("FAIL: async reset"); end

        $display ("==== DONE: %0d errors, %0d off-edge output changes ====", errors, glitches);
        $fdisplay(log_fd, "==== DONE: %0d errors, %0d off-edge output changes ====", errors, glitches);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
