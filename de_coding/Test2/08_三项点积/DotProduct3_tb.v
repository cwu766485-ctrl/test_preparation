`timescale 1ns/1ps
// ============================================================
// 测试平台：验证三项有符号点积。
// InputVector.txt 首行是说明；每行六个有符号十进制数，依次为 A2 B2 A1 B1 A0 B0。
// 每拍送一项，每组共三拍；仅第一组的第一项同时给 START=1。
// 每次 OUT_STROBE 为 1，就将 OUT 与独立整数算式比较。
// 完整时钟周期为 2×CLK_T=20 ns。
// ============================================================
module DotProduct3_tb;
    parameter CLK_T = 10;
    parameter N     = 32;

    reg                CLK, NRST, START;
    reg  signed [7:0]  A, B;
    wire signed [17:0] OUT;
    wire               OUT_STROBE;

    integer a2 [0:N-1], b2 [0:N-1], a1 [0:N-1], b1 [0:N-1], a0 [0:N-1], b0 [0:N-1];
    integer n_vec, n_res, i, r, fd, log_fd, errors, expected;
    reg [8*256-1:0] header;

    DotProduct3 U1 (.CLK(CLK), .NRST(NRST), .START(START),
                    .A(A), .B(B), .OUT(OUT), .OUT_STROBE(OUT_STROBE));

`ifdef GATE_SIM
    initial $sdf_annotate("Syn_DotProduct3.sdf", U1);
`endif

`ifdef VCS
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, DotProduct3_tb);
    end
`endif

    initial CLK = 1'b0;
    always #CLK_T CLK = ~CLK;

    always @(posedge CLK) begin
        #2;
        if (NRST && OUT_STROBE) begin
            expected = a2[n_res]*b2[n_res] + a1[n_res]*b1[n_res] + a0[n_res]*b0[n_res];
            if ($signed(OUT) !== expected) begin
                errors = errors + 1;
                $display ("FAIL vector %0d: OUT=%0d expected %0d", n_res, $signed(OUT), expected);
                $fdisplay(log_fd, "FAIL vector %0d: OUT=%0d expected %0d", n_res, $signed(OUT), expected);
            end else begin
                $display ("PASS vector %0d: OUT=%0d", n_res, $signed(OUT));
                $fdisplay(log_fd, "PASS vector %0d: (%0d)(%0d)+(%0d)(%0d)+(%0d)(%0d) = %0d", n_res,
                          a2[n_res], b2[n_res], a1[n_res], b1[n_res], a0[n_res], b0[n_res], $signed(OUT));
            end
            n_res = n_res + 1;
        end
    end

    initial begin
        fd = $fopen("InputVector.txt", "r");
        if (fd == 0) begin $display("FAIL: InputVector.txt not found"); $finish; end
        r = $fgets(header, fd);
        n_vec = 0;
        while (!$feof(fd) && n_vec < N) begin
            r = $fscanf(fd, "%d %d %d %d %d %d\n", a2[n_vec], b2[n_vec], a1[n_vec], b1[n_vec], a0[n_vec], b0[n_vec]);
            if (r == 6) n_vec = n_vec + 1;
        end
        $fclose(fd);
        log_fd = $fopen("Check.txt", "w");
        errors = 0; n_res = 0;

        NRST = 0; START = 0; A = 0; B = 0;
        repeat (2) @(negedge CLK);
        NRST = 1;

        for (i = 0; i < n_vec; i = i + 1) begin
            @(negedge CLK); A = a2[i]; B = b2[i]; START = (i == 0);
            @(negedge CLK); A = a1[i]; B = b1[i]; START = 0;
            @(negedge CLK); A = a0[i]; B = b0[i];
        end
        repeat (3) @(posedge CLK);
        #3;

        if (n_res != n_vec) begin errors = errors + 1; $display("FAIL: got %0d results for %0d vectors", n_res, n_vec); end
        $display ("==== DONE: %0d vectors, %0d errors ====", n_vec, errors);
        $fdisplay(log_fd, "==== DONE: %0d vectors, %0d errors ====", n_vec, errors);
        $fclose(log_fd);
`ifdef VCS
        $vcdplusoff;
`endif
        $finish;
    end
endmodule
