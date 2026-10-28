`timescale 1ns/1ps
module SerialAdder_tb;
    parameter CLK_T = 10;  // 半周期 10 ns；综合约束示例为 20 ns。

    reg CLK, NRST, START;
    reg [15:0] A, B;
    reg [4:0] N;
    wire [15:0] SUM;
    wire COUT, DONE;
    integer errors, tests, width, cycles, i, fd;
    reg [15:0] mask, expected_sum;
    reg [16:0] full;
    reg expected_cout;

    SerialAdder U1 (
        .CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B), .N(N),
        .SUM(SUM), .COUT(COUT), .DONE(DONE)
    );

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SerialAdder.sdf", U1);
`endif
`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SerialAdder_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    task check_add(input [15:0] aa, input [15:0] bb, input [4:0] nn);
        begin
            width = (nn == 0 || nn > 16) ? 16 : nn;
            mask = (width == 16) ? 16'hFFFF : ((16'h0001 << width) - 16'd1);
            full = {1'b0, (aa & mask)} + {1'b0, (bb & mask)};
            expected_sum = full[15:0] & mask;
            expected_cout = full[width];

            @(negedge CLK);
            A = aa; B = bb; N = nn; START = 1'b1;
            @(negedge CLK);  // START 已在前一个上升沿被采样。
            START = 1'b0;
            A = ~aa; B = ~bb; N = 5'd1; // 外部输入改变，验证内部已锁存。

            cycles = 0;
            while (DONE !== 1'b1 && cycles < 20) begin
                START = (cycles == 0 && width > 2); // 忙时再给一次 START，应被忽略。
                @(negedge CLK);
                cycles = cycles + 1;
            end
            START = 1'b0;
            tests = tests + 1;
            if (DONE !== 1'b1 || cycles != width ||
                SUM !== expected_sum || COUT !== expected_cout) begin
                errors = errors + 1;
                $display("FAIL A=%h B=%h N=%0d SUM=%h COUT=%b DONE=%b cycles=%0d (expect %h %b %0d)",
                         aa, bb, nn, SUM, COUT, DONE, cycles,
                         expected_sum, expected_cout, width);
                $fdisplay(fd, "FAIL A=%h B=%h N=%0d", aa, bb, nn);
            end else begin
                $display("PASS A=%h B=%h N=%0d -> SUM=%h COUT=%b in %0d cycles",
                         aa, bb, nn, SUM, COUT, cycles);
                $fdisplay(fd, "PASS A=%h B=%h N=%0d", aa, bb, nn);
            end
        end
    endtask

    initial begin
        fd = $fopen("Check.txt", "w");
        if (fd == 0) begin
            $display("ERROR: cannot open Check.txt");
            $finish;
        end
        errors = 0; tests = 0;
        NRST = 1'b0; START = 1'b0; A = 0; B = 0; N = 0;
        repeat (2) @(negedge CLK);
        NRST = 1'b1;

        check_add(16'd5,    16'd3,    5'd4);
        check_add(16'd9,    16'd8,    5'd4);
        check_add(16'hFFFF, 16'h0001, 5'd16);
        check_add(16'h0001, 16'h0001, 5'd1);
        check_add(16'hABCD, 16'h1234, 5'd8);
        check_add(16'd5,    16'd3,    5'd0);
        check_add(16'd5,    16'd3,    5'd17);
        for (i = 1; i <= 16; i = i + 1)
            check_add(16'hA5C3 + i, 16'h1F07 + i, i);

        $display("DONE: %0d tests, %0d errors", tests, errors);
        $fdisplay(fd, "DONE: %0d tests, %0d errors", tests, errors);
        $fclose(fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
