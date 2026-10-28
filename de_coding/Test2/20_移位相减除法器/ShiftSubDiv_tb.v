`timescale 1ns/1ps
// 第20题测试：8 位无符号除法。先测边界值，再测 300 组随机输入；定义 FULL 时穷举全部 65536 组。
// B 非零时核对 Q=A/B、R=A%B、DIV0=0；B 为零时核对 Q=255、R=A、DIV0=1。
// 还核对 DONE 出现的拍数恰为 START 之后 W+1 拍；时钟周期为 2*CLK_T=20 ns。
module ShiftSubDiv_tb;
    parameter CLK_T = 10;
    parameter W     = 8;

    reg          CLK, NRST, START;
    reg  [W-1:0] A, B;
    wire [W-1:0] Q, R;
    wire         DIV0, DONE;

    integer i, j, seed, errors, tests, cycles, log_fd;
    reg [W-1:0] eq, er;
    reg         ez;

    ShiftSubDiv U1 (.CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B),
                    .Q(Q), .R(R), .DIV0(DIV0), .DONE(DONE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_ShiftSubDiv.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, ShiftSubDiv_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    task run_div(input [W-1:0] a, input [W-1:0] b);
        begin
            @(negedge CLK);
            A = a; B = b; START = 1'b1;
            @(negedge CLK);
            START = 1'b0; A = ~a; B = ~b;
            cycles = 1;
            while (DONE !== 1'b1) begin
                @(negedge CLK);
                cycles = cycles + 1;
                if (cycles > 3 * W) begin $display("FAIL: no DONE"); errors = errors + 1; disable run_div; end
            end
            if (b == 0) begin eq = {W{1'b1}}; er = a; ez = 1'b1; end
            else        begin eq = a / b;     er = a % b; ez = 1'b0; end
            tests = tests + 1;
            if (Q !== eq || R !== er || DIV0 !== ez || cycles != W + 1) begin
                errors = errors + 1;
                $display ("FAIL %0d / %0d -> Q=%0d R=%0d DIV0=%b (exp %0d %0d %b), %0d clk", a, b, Q, R, DIV0, eq, er, ez, cycles);
                $fdisplay(log_fd, "FAIL %0d / %0d -> Q=%0d R=%0d (exp %0d %0d)", a, b, Q, R, eq, er);
            end else if (tests <= 400)
                $fdisplay(log_fd, "PASS %0d / %0d = %0d remainder %0d", a, b, Q, R);
        end
    endtask

    initial begin
        log_fd = $fopen("Check.txt", "w");
        errors = 0; tests = 0; seed = 20;
        NRST = 0; START = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        run_div(13, 4);    run_div(100, 7);  run_div(255, 1);   run_div(255, 255);
        run_div(0, 5);     run_div(7, 9);    run_div(128, 2);   run_div(200, 16);
        run_div(255, 254); run_div(42, 0);   run_div(0, 0);
`ifdef FULL
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                run_div(i, j);
`else
        for (i = 0; i < 300; i = i + 1)
            run_div($random(seed), $random(seed));
`endif
        $display ("==== DONE: %0d divisions, %0d errors ====", tests, errors);
        $fdisplay(log_fd, "==== DONE: %0d divisions, %0d errors ====", tests, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
