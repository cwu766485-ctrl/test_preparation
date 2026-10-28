`timescale 1ns/1ps
// 第25题测试：每个上升沿后等 2 ns 检查灯色，避免与非阻塞赋值更新同时读取。
// 检查每路只有一盏灯、两路不会同时非红、相位顺序、各相位时长和 CAR 触发条件。
// 覆盖无车、提前来车、持续有车、短脉冲及随机 CAR；完整时钟周期 2*CLK_T=20 ns。
module TrafficLight_tb;
    parameter CLK_T = 10;
    parameter T_MG = 6, T_Y = 2, T_SG = 4;

    reg        CLK, NRST, CAR;
    wire [2:0] MAIN, SIDE;

    localparam MG = 0, MY = 1, SG = 2, SY = 3;
    integer phase, prev_phase, len, errors, cycles, cycles_sg, i, seed, log_fd;
    reg     car_at_edge;

    TrafficLight U1 (.CLK(CLK), .NRST(NRST), .CAR(CAR), .MAIN(MAIN), .SIDE(SIDE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_TrafficLight.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, TrafficLight_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    // 把两路灯色解码成相位编号；−1 代表非法组合
    function integer decode(input [2:0] m, input [2:0] s);
        begin
            if      (m == 3'b001 && s == 3'b100) decode = MG;
            else if (m == 3'b010 && s == 3'b100) decode = MY;
            else if (m == 3'b100 && s == 3'b001) decode = SG;
            else if (m == 3'b100 && s == 3'b010) decode = SY;
            else                                 decode = -1;
        end
    endfunction

    task fail(input [8*60-1:0] msg);
        begin
            errors = errors + 1;
            $display ("FAIL t=%0t: %0s (MAIN=%b SIDE=%b)", $time, msg, MAIN, SIDE);
            $fdisplay(log_fd, "FAIL t=%0t: %0s", $time, msg);
        end
    endtask

    // 在每组结果有效时进行核对
    always @(posedge CLK) begin
        car_at_edge = CAR;                       // 记录状态机在此上升沿读取到的 CAR
        #2;
        if (NRST) begin
            cycles = cycles + 1;
            phase  = decode(MAIN, SIDE);
            if (MAIN != 3'b100 && SIDE != 3'b100) fail("SAFETY: both roads not red");
            if (phase < 0) fail("illegal light combination");
            else if (phase == prev_phase) begin
                len = len + 1;
                // 最短主绿时间已到且有车时，必须立即离开主绿状态
                if (phase == MG && len > T_MG && car_at_edge) fail("MG did not react to CAR");
            end else begin
                // 相位变化时，核对转换顺序和刚结束相位的时长
                if (phase != (prev_phase + 1) % 4) fail("wrong phase order");
                case (prev_phase)
                    MG: begin if (len < T_MG) fail("MG too short"); if (!car_at_edge) fail("left MG without CAR"); end
                    MY: if (len != T_Y)  fail("MY wrong length");
                    SG: begin if (len != T_SG) fail("SG wrong length"); cycles_sg = cycles_sg + 1; end
                    SY: if (len != T_Y)  fail("SY wrong length");
                endcase
                $fdisplay(log_fd, "t=%0t phase %0d -> %0d after %0d clocks", $time, prev_phase, phase, len);
                prev_phase = phase;
                len = 1;
            end
        end
    end

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; cycles = 0; cycles_sg = 0; seed = 25;
        prev_phase = MG; len = 0;
        NRST = 0; CAR = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        repeat (20) @(negedge CLK);              // 场景一：无车时主路必须保持绿灯
        if (decode(MAIN, SIDE) != MG) fail("left MG without any car");
        CAR = 1;                                 // 场景二：最短主绿时间已过后有车到达
        repeat (3) @(negedge CLK);
        CAR = 0;
        repeat (15) @(negedge CLK);
        CAR = 1;                                 // 场景三：持续有车，检查周期性切换
        repeat (40) @(negedge CLK);
        CAR = 0;
        repeat (10) @(negedge CLK);
        for (i = 0; i < 300; i = i + 1) begin    // 场景四：随机来车，包含仅一拍的短脉冲
            @(negedge CLK);
            CAR = (($random(seed) & 7) == 0);
        end
        CAR = 0;
        repeat (20) @(negedge CLK);

        if (cycles_sg < 5) fail("too few side-green phases tested");
        $display ("==== DONE: %0d clocks, %0d side-green phases, %0d errors ====", cycles, cycles_sg, errors);
        $fdisplay(log_fd, "==== DONE: %0d clocks, %0d side-green phases, %0d errors ====", cycles, cycles_sg, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
