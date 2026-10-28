`timescale 1ns/1ps

module tb_matrix_mul_2x2;
    reg clk;
    reg rst_n;
    reg start;
    reg [31:0] A_flat, B_flat;

    wire [16:0] C00, C01, C10, C11;
    wire busy, done;
    integer checks, cases, i, j;
    reg [31:0] rng;

    matrix_mul_2x2 dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .A_flat(A_flat), .B_flat(B_flat),
        .C00(C00), .C01(C01), .C10(C10), .C11(C11),
        .busy(busy), .done(done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("matrix_mul_2x2_rtl.vcd");
        $dumpvars(0, tb_matrix_mul_2x2);
    end

    function automatic [31:0] pack4(
        input [7:0] d00, input [7:0] d01,
        input [7:0] d10, input [7:0] d11
    );
        pack4 = {d00, d01, d10, d11};
    endfunction

    task automatic check_outputs(
        input [16:0] e00, input [16:0] e01,
        input [16:0] e10, input [16:0] e11,
        input exp_busy, input exp_done
    );
        begin
            checks = checks + 1;
            if (C00 !== e00 || C01 !== e01 ||
                C10 !== e10 || C11 !== e11 ||
                busy !== exp_busy || done !== exp_done) begin
                $display("EXPECTED C=%0d,%0d,%0d,%0d busy=%b done=%b",
                         e00,e01,e10,e11,exp_busy,exp_done);
                $display("GOT      C=%0d,%0d,%0d,%0d busy=%b done=%b",
                         C00,C01,C10,C11,busy,done);
                $fatal(1, "FAIL case=%0d time=%0t",cases,$time);
            end
        end
    endtask

    task automatic run_case(
        input [31:0] aa, input [31:0] bb, input disturb
    );
        reg [16:0] e00,e01,e10,e11;
        integer k;
        begin
            cases = cases + 1;
            e00=17'd0; e01=17'd0; e10=17'd0; e11=17'd0;
            @(negedge clk);
            A_flat=aa; B_flat=bb; start=1'b1;
            @(posedge clk); #1;
            check_outputs(17'd0,17'd0,17'd0,17'd0,1'b1,1'b0);

            for (k=0; k<8; k=k+1) begin
                @(negedge clk);
                start = (disturb && k==4); // busy start MUST be ignored
                if (disturb && k>=2) begin
                    A_flat = ~aa; B_flat = ~bb; // must NOT affect latched job
                end
                @(posedge clk); #1;
                case (k)
                    0: e00 = e00 + (aa[31:24] * bb[31:24]);
                    1: e00 = e00 + (aa[23:16] * bb[15:8]);
                    2: e01 = e01 + (aa[31:24] * bb[23:16]);
                    3: e01 = e01 + (aa[23:16] * bb[7:0]);
                    4: e10 = e10 + (aa[15:8]  * bb[31:24]);
                    5: e10 = e10 + (aa[7:0]   * bb[15:8]);
                    6: e11 = e11 + (aa[15:8]  * bb[23:16]);
                    7: e11 = e11 + (aa[7:0]   * bb[7:0]);
                endcase
                check_outputs(e00,e01,e10,e11,(k!=7),(k==7));
            end

            @(negedge clk); start=1'b0;
            @(posedge clk); #1;
            check_outputs(e00,e01,e10,e11,1'b0,1'b0);
            $display("PASS case=%0d A=%h B=%h C=%0d,%0d,%0d,%0d",
                     cases,aa,bb,e00,e01,e10,e11);
        end
    endtask

    task automatic test_reset_during_run;
        begin
            cases = cases+1;
            @(negedge clk);
            A_flat=32'hFFFFFFFF;
            B_flat=32'hFFFFFFFF;
            start=1'b1;
            @(posedge clk); #1;
            check_outputs(0,0,0,0,1,0);
            @(negedge clk); start=1'b0;
            repeat (3) @(posedge clk);
            #1;
            if (busy !== 1'b1) $fatal(1,"busy dropped too early");

            // Asynchronous reset: no rising edge required to clear outputs.
            @(negedge clk); #1;
            rst_n=1'b0; #1;
            check_outputs(0,0,0,0,0,0);
            repeat (2) @(posedge clk);
            @(negedge clk); rst_n=1'b1;
            @(posedge clk); #1;
            check_outputs(0,0,0,0,0,0);
            $display("PASS reset while busy");
        end
    endtask

    initial begin
        checks=0; cases=0; rng=32'h45D9F3B;
        rst_n=1'b0; start=1'b0;
        A_flat=0; B_flat=0;
        repeat (2) @(posedge clk);
        #1;
        check_outputs(0,0,0,0,0,0);
        @(negedge clk); rst_n=1'b1;

        // TC01: normal example yields [19 22; 43 50].
        run_case(pack4(1,2,3,4),pack4(5,6,7,8),0);
        // TC02, TC03, TC04: zeros, identity, max (130050 = 17 bits).
        run_case(pack4(0,0,0,0),pack4(5,6,7,8),0);
        run_case(pack4(1,0,0,1),pack4(3,4,5,6),0);
        run_case(pack4(255,255,255,255),pack4(255,255,255,255),0);
        // TC05 + TC06: changed live inputs & start pulse while busy.
        run_case(pack4(12,34,56,78),pack4(90,87,65,43),1);
        // TC07: asynchronous reset during active calculation.
        test_reset_during_run();
        // Verify recovery after reset.
        run_case(pack4(2,0,1,2),pack4(1,1,1,1),0);

        // >= 100 deterministic pseudo-random cases, independent model.
        for (i=0;i<120;i=i+1) begin
            rng=rng*32'd1664525+32'd1013904223;
            A_flat=rng;
            rng=rng*32'd1664525+32'd1013904223;
            B_flat=rng;
            // The run_case captures these values before driving any DUT input.
            run_case(A_flat,B_flat,(i%13)==0);
        end

        $display("PASS ALL: %0d cases, %0d cycle-by-cycle checks",
                 cases,checks);
        $finish;
    end

    initial begin
        #2000000;
        $fatal(1,"TIMEOUT: test did not finish");
    end
endmodule
