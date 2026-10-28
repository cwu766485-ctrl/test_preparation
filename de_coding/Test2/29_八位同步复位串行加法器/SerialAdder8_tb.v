`timescale 1ns/1ps
module SerialAdder8_tb;
    parameter CLK_T = 10;
    reg CLK, NRST, START;
    reg [7:0] A, B;
    reg [3:0] N;
    wire [7:0] SUM;
    wire COUT, DONE;
    integer tests, errors, width, cycles, i, fd;
    reg [7:0] mask, expected_sum, old_sum;
    reg [8:0] full;
    reg expected_cout;

    SerialAdder8 U1 (
        .CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B), .N(N),
        .SUM(SUM), .COUT(COUT), .DONE(DONE)
    );

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_SerialAdder8.sdf", U1);
`endif
`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, SerialAdder8_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    task check_add(input [7:0] aa, input [7:0] bb, input [3:0] nn);
        begin
            width = (nn == 0 || nn > 8) ? 8 : nn;
            mask = (width == 8) ? 8'hFF : ((8'h01 << width) - 8'd1);
            full = {1'b0, (aa & mask)} + {1'b0, (bb & mask)};
            expected_sum = full[7:0] & mask;
            expected_cout = full[width];

            @(negedge CLK);
            A = aa; B = bb; N = nn; START = 1'b1;
            @(negedge CLK); // 装载沿已经过去。
            START = 1'b0;
            A = ~aa; B = ~bb; N = 4'd1; // 验证输入已锁存。

            cycles = 0;
            while (DONE !== 1'b1 && cycles < 12) begin
                START = (cycles == 0 && width > 2); // 运行时重复 START，应被忽略。
                @(negedge CLK);
                cycles = cycles + 1;
            end
            START = 1'b0;
            tests = tests + 1;
            if (DONE !== 1'b1 || cycles != width ||
                SUM !== expected_sum || COUT !== expected_cout) begin
                errors = errors + 1;
                $display("FAIL A=%h B=%h N=%0d -> SUM=%h COUT=%b DONE=%b cycles=%0d; expect %h %b %0d",
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
        errors = 0; tests = 0;
        NRST = 1'b0; START = 1'b0; A = 0; B = 0; N = 0;
        repeat (2) @(negedge CLK);
        NRST = 1'b1;

        check_add(8'd5, 8'd3, 4'd4);
        check_add(8'hFF, 8'h01, 4'd8);
        check_add(8'h01, 8'h01, 4'd1);
        check_add(8'hA5, 8'h36, 4'd5);
        check_add(8'd5, 8'd3, 4'd0);
        check_add(8'd5, 8'd3, 4'd9);
        for (i = 1; i <= 8; i = i + 1)
            check_add(8'hA5 + i, 8'h36 + i, i);

        // 专门检查“同步”二字：NRST 拉低后、下个上升沿前，输出应仍保持旧值。
        check_add(8'd3, 8'd4, 4'd8);
        old_sum = SUM;
        @(negedge CLK);
        NRST = 1'b0;
        #1;
        tests = tests + 1;
        if (SUM !== old_sum) begin
            errors = errors + 1;
            $display("FAIL synchronous reset changed SUM before CLK edge");
            $fdisplay(fd, "FAIL reset changed before CLK edge");
        end else begin
            $display("PASS reset does not act before CLK edge");
            $fdisplay(fd, "PASS reset does not act before CLK edge");
        end
        @(negedge CLK); // 中间经历了一个上升沿，输出现在必须被清零。
        tests = tests + 1;
        if (SUM !== 8'd0 || COUT !== 1'b0 || DONE !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL reset after CLK edge SUM=%h COUT=%b DONE=%b", SUM, COUT, DONE);
            $fdisplay(fd, "FAIL reset after CLK edge");
        end else begin
            $display("PASS reset acts at CLK edge");
            $fdisplay(fd, "PASS reset acts at CLK edge");
        end
        NRST = 1'b1;

        $display("DONE: %0d tests, %0d errors", tests, errors);
        $fdisplay(fd, "DONE: %0d tests, %0d errors", tests, errors);
        $fclose(fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
