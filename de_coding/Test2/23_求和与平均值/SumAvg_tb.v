`timescale 1ns/1ps
// 第23题测试：每组 8 个数，包含全零、全 255、1～8、舍入边界和随机数据。
// 组间随机插入空闲拍；在组内故意再次置 START，检查它不会重新开始累计。
// 核对 SUM、向下取整 AVG、四舍五入 AVG_R，以及从 START 起第 N 拍出现的 DONE。
module SumAvg_tb;
    parameter CLK_T = 10;
    parameter N     = 8;

    reg         CLK, NRST, START;
    reg  [7:0]  DIN;
    wire [10:0] SUM;
    wire [7:0]  AVG, AVG_R;
    wire        DONE;

    integer blk, k, seed, errors, tests, s, gap, log_fd;
    reg [7:0] v [0:N-1];

    SumAvg U1 (.CLK(CLK), .NRST(NRST), .START(START), .DIN(DIN),
               .SUM(SUM), .AVG(AVG), .AVG_R(AVG_R), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SumAvg.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SumAvg_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; tests = 0; seed = 23;
        NRST = 0; START = 0; DIN = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (blk = 0; blk < 60; blk = blk + 1) begin
            for (k = 0; k < N; k = k + 1) begin
                case (blk)
                    0: v[k] = 0;
                    1: v[k] = 255;
                    2: v[k] = k + 1;                    // 1～8 的和为 36，平均 4.5；截断为 4、四舍五入为 5
                    3: v[k] = (k == 0) ? 3 : 0;         // 总和 3，平均 0.375；两种结果均为 0
                    4: v[k] = (k == 0) ? 4 : 0;         // 总和 4，平均 0.5；截断为 0、四舍五入为 1
                    default: v[k] = $random(seed);
                endcase
            end
            s = 0;
            for (k = 0; k < N; k = k + 1) begin
                @(negedge CLK);
                DIN = v[k]; START = (k == 0) || (k == 3);   // k=3 时的第二次 START 必须被忽略
                s = s + v[k];
            end
            @(negedge CLK);
            START = 0; DIN = 8'hA5;                     // 此拍 DIN 是干扰值，不能累加；DONE 此时应有效
            tests = tests + 1;
            if (DONE !== 1'b1 || SUM !== s || AVG !== (s / 8) || AVG_R !== ((s + 4) / 8)) begin
                errors = errors + 1;
                $display ("FAIL block %0d: DONE=%b SUM=%0d AVG=%0d AVG_R=%0d (exp %0d %0d %0d)",
                          blk, DONE, SUM, AVG, AVG_R, s, s / 8, (s + 4) / 8);
                $fdisplay(log_fd, "FAIL block %0d: SUM=%0d AVG=%0d AVG_R=%0d (exp %0d %0d %0d)", blk, SUM, AVG, AVG_R, s, s / 8, (s + 4) / 8);
            end else
                $fdisplay(log_fd, "PASS block %0d: SUM=%0d AVG=%0d AVG_R=%0d", blk, SUM, AVG, AVG_R);
            DIN = 0;
            gap = $random(seed) & 3;                    // 两组之间随机空闲 0～3 拍
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
