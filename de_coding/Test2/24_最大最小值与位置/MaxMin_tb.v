`timescale 1ns/1ps
// 第24题测试：覆盖全相同、递增、递减、最大值在最后、最大值重复及随机输入。
// 组间插入空闲拍，组内故意再次给 START，检查该信号会被忽略。
// 参考结果逐个扫描输入，核对 MAX/MIN/IMAX；重复最大值必须保留最早位置。
module MaxMin_tb;
    parameter CLK_T = 10;
    parameter N     = 8;

    reg        CLK, NRST, START;
    reg  [7:0] DIN;
    wire [7:0] MAX, MIN;
    wire [2:0] IMAX;
    wire       DONE;

    integer blk, k, seed, errors, tests, gap, log_fd;
    integer emax, emin, eimax;
    reg [7:0] v [0:N-1];

    MaxMin U1 (.CLK(CLK), .NRST(NRST), .START(START), .DIN(DIN),
               .MAX(MAX), .MIN(MIN), .IMAX(IMAX), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_MaxMin.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, MaxMin_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; tests = 0; seed = 24;
        NRST = 0; START = 0; DIN = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (blk = 0; blk < 60; blk = blk + 1) begin
            for (k = 0; k < N; k = k + 1)
                case (blk)
                    0: v[k] = 8'd77;                       // 全部相同，首次最大值位置是 0
                    1: v[k] = 10 * k;                      // 递增，最大值在位置 7
                    2: v[k] = 200 - 10 * k;                // 递减，最大值在 0、最小值在 7
                    3: v[k] = (k == 7) ? 255 : k;          // 最大值在最后一个位置
                    4: v[k] = (k == 2 || k == 5) ? 99 : 1; // 最大值重复，必须返回首次出现的位置 2
                    5: v[k] = (k == 4) ? 0 : 128;          // 最小值出现在中间
                    default: v[k] = $random(seed);
                endcase
            // 计算独立的期望结果
            emax = v[0]; emin = v[0]; eimax = 0;
            for (k = 1; k < N; k = k + 1) begin
                if (v[k] > emax) begin emax = v[k]; eimax = k; end
                if (v[k] < emin) emin = v[k];
            end
            for (k = 0; k < N; k = k + 1) begin
                @(negedge CLK);
                DIN = v[k]; START = (k == 0) || (k == 5);  // 组内 k=5 的 START 必须被忽略
            end
            @(negedge CLK);
            START = 0; DIN = 8'hFF;                         // 空闲拍的 DIN 不应计入本组结果
            tests = tests + 1;
            if (DONE !== 1'b1 || MAX !== emax || MIN !== emin || IMAX !== eimax) begin
                errors = errors + 1;
                $display ("FAIL block %0d: DONE=%b MAX=%0d MIN=%0d IMAX=%0d (exp %0d %0d %0d)",
                          blk, DONE, MAX, MIN, IMAX, emax, emin, eimax);
                $fdisplay(log_fd, "FAIL block %0d: MAX=%0d MIN=%0d IMAX=%0d (exp %0d %0d %0d)", blk, MAX, MIN, IMAX, emax, emin, eimax);
            end else
                $fdisplay(log_fd, "PASS block %0d: MAX=%0d (at %0d) MIN=%0d", blk, MAX, IMAX, MIN);
            DIN = 0;
            gap = $random(seed) & 3;
            repeat (gap) @(negedge CLK);
        end

        $display ("==== DONE: %0d blocks, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d blocks, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
