`timescale 1ns/1ps

module tb_q4_q5_q6;

    integer errors;

    // ============================================================
    // Q4 Comparator
    // ============================================================

    reg  [7:0] cmp_a;
    reg  [7:0] cmp_b;
    wire       cmp_eq;
    wire       cmp_gt;
    wire       cmp_lt;

    comparator #(
        .W(8)
    ) u_comparator (
        .a  (cmp_a),
        .b  (cmp_b),
        .eq (cmp_eq),
        .gt (cmp_gt),
        .lt (cmp_lt)
    );


    // ============================================================
    // Q5 Parity
    // ============================================================

    reg  [7:0] parity_data;
    wire       even_p;
    wire       odd_p;

    parity_gen u_parity (
        .data   (parity_data),
        .even_p (even_p),
        .odd_p  (odd_p)
    );


    // ============================================================
    // Q6 Binary / Gray
    // ============================================================

    reg  [7:0] bin;
    wire [7:0] gray;

    reg  [7:0] gray_in;
    wire [7:0] bin_out;

    bin_gray #(
        .W(8)
    ) u_bin_gray (
        .bin      (bin),
        .gray     (gray),

        .gray_in  (gray_in),
        .bin_out  (bin_out)
    );


    // ============================================================
    // Q4 check task
    // ============================================================

    task automatic check_cmp(
        input [7:0] a,
        input [7:0] b
    );
        reg exp_eq;
        reg exp_gt;
        reg exp_lt;

        begin

            cmp_a = a;
            cmp_b = b;

            #1;

            exp_eq = (a == b);
            exp_gt = (a > b);
            exp_lt = (a < b);

            if ((cmp_eq !== exp_eq) ||
                (cmp_gt !== exp_gt) ||
                (cmp_lt !== exp_lt)) begin

                $display(
                    "[CMP ERROR] a=%0d b=%0d | eq=%b gt=%b lt=%b | expected=%b %b %b",
                    a, b,
                    cmp_eq, cmp_gt, cmp_lt,
                    exp_eq, exp_gt, exp_lt
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "[CMP PASS ] a=%0d b=%0d | eq=%b gt=%b lt=%b",
                    a, b,
                    cmp_eq, cmp_gt, cmp_lt
                );

            end

        end
    endtask


    // ============================================================
    // Q5 check task
    // ============================================================

    task automatic check_parity(
        input [7:0] data
    );

        integer i;
        integer one_count;

        reg expected_even;
        reg expected_odd;

        begin

            parity_data = data;

            one_count = 0;

            for (i = 0; i < 8; i = i + 1) begin
                if (data[i])
                    one_count = one_count + 1;
            end

            #1;

            // 如果 data 中 1 的个数为奇数
            // even parity bit 必须补 1
            expected_even = one_count % 2;

            // odd parity 正好反过来
            expected_odd = !(one_count % 2);

            if ((even_p !== expected_even) ||
                (odd_p  !== expected_odd)) begin

                $display(
                    "[PARITY ERROR] data=%b ones=%0d even=%b odd=%b expected=%b %b",
                    data,
                    one_count,
                    even_p,
                    odd_p,
                    expected_even,
                    expected_odd
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "[PARITY PASS ] data=%b ones=%0d even=%b odd=%b",
                    data,
                    one_count,
                    even_p,
                    odd_p
                );

            end

        end
    endtask


    // ============================================================
    // Q6 check task
    // ============================================================

    task automatic check_bin_gray(
        input [7:0] binary
    );

        reg [7:0] expected_gray;

        begin

            bin = binary;

            #1;

            expected_gray = binary ^ (binary >> 1);

            // --------------------------
            // binary -> gray check
            // --------------------------

            if (gray !== expected_gray) begin

                $display(
                    "[BIN2GRAY ERROR] bin=%b gray=%b expected=%b",
                    binary,
                    gray,
                    expected_gray
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "[BIN2GRAY PASS ] bin=%b gray=%b",
                    binary,
                    gray
                );

            end


            // --------------------------
            // gray -> binary check
            // --------------------------

            gray_in = gray;

            #1;

            if (bin_out !== binary) begin

                $display(
                    "[GRAY2BIN ERROR] gray=%b bin_out=%b expected=%b",
                    gray,
                    bin_out,
                    binary
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "[GRAY2BIN PASS ] gray=%b bin=%b",
                    gray,
                    bin_out
                );

            end

        end
    endtask



    // ============================================================
    // Main Test
    // ============================================================

    initial begin

        errors = 0;

        cmp_a       = 0;
        cmp_b       = 0;
        parity_data = 0;
        bin         = 0;
        gray_in     = 0;

        $dumpfile("q4_q5_q6.vcd");
        $dumpvars(0, tb_q4_q5_q6);


        // ========================================================
        // Q4 Comparator Test
        // ========================================================

        $display("\n========== Q4 Comparator ==========");

        check_cmp(8'd0,   8'd0);
        check_cmp(8'd10,  8'd20);
        check_cmp(8'd20,  8'd10);
        check_cmp(8'd255, 8'd1);
        check_cmp(8'd128, 8'd128);


        // ========================================================
        // Q5 Parity Test
        // ========================================================

        $display("\n========== Q5 Parity ==========");

        check_parity(8'b0000_0000);
        check_parity(8'b0000_0001);
        check_parity(8'b1011_0010);
        check_parity(8'b1011_0011);
        check_parity(8'b1111_1111);


        // ========================================================
        // Q6 Binary <-> Gray
        // ========================================================

        $display("\n========== Q6 Binary / Gray ==========");

        check_bin_gray(8'b0000_0000);
        check_bin_gray(8'b0000_0001);
        check_bin_gray(8'b0000_0010);
        check_bin_gray(8'b0000_0011);
        check_bin_gray(8'b0000_1011);
        check_bin_gray(8'b1011_0110);
        check_bin_gray(8'b1111_1111);


        // ========================================================
        // Final Report
        // ========================================================

        if (errors == 0) begin
            $display("\n=================================");
            $display("       ALL TESTS PASSED");
            $display("=================================\n");
        end
        else begin
            $display("\n=================================");
            $display("       TEST FAILED");
            $display("       errors = %0d", errors);
            $display("=================================\n");
        end

        #10;
        $finish;

    end

endmodule