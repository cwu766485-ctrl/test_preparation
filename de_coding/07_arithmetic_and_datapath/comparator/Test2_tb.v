module tb_Test2;

    reg  [2:0] A1, A2, A3, A4;
    wire       open;

    integer i, found, errors;

    Test2 dut (
        .A1(A1), .A2(A2), .A3(A3), .A4(A4),
        .open(open)
    );

    task apply_code;
        input [2:0] d1, d2, d3, d4;
        input       expected;
        begin
            {A1, A2, A3, A4} = {d1, d2, d3, d4};
            #10;
            if (open !== expected) begin
                $display("FAIL: code %0d%0d%0d%0d  open=%b (expected %b)",
                         d1, d2, d3, d4, open, expected);
                errors = errors + 1;
            end else
                $display("PASS: code %0d%0d%0d%0d  open=%b",
                         d1, d2, d3, d4, open);
        end
    endtask

    initial begin
        $dumpfile("tb_Test2.vcd");
        $dumpvars(0, tb_Test2);

        $timeformat(-9, 0, " ns", 0);
        errors = 0;
        found  = 0;

        // ---------- Part 1: directed tests ----------
        $display("=== Directed tests ===");
        apply_code(3'd0, 3'd1, 3'd0, 3'd7, 1'b1);   // correct code 0107
        apply_code(3'd0, 3'd0, 3'd0, 3'd0, 1'b0);   // all zero
        apply_code(3'd7, 3'd7, 3'd7, 3'd7, 1'b0);   // all seven
        apply_code(3'd1, 3'd1, 3'd0, 3'd7, 1'b0);   // digit 1 wrong
        apply_code(3'd0, 3'd2, 3'd0, 3'd7, 1'b0);   // digit 2 wrong
        apply_code(3'd0, 3'd1, 3'd3, 3'd7, 1'b0);   // digit 3 wrong
        apply_code(3'd0, 3'd1, 3'd0, 3'd6, 1'b0);   // digit 4 wrong
        apply_code(3'd7, 3'd0, 3'd1, 3'd0, 1'b0);   // reversed order

        // ---------- Part 2: number generator, exhaustive search ----------
        $display("=== Exhaustive search over 4096 codes ===");
        for (i = 0; i < 4096; i = i + 1) begin
            {A1, A2, A3, A4} = i[11:0];
            #10;
            if (open) begin
                found = found + 1;
                $display("Relay OPEN at t=%0t, code = %0d%0d%0d%0d",
                         $time, A1, A2, A3, A4);
            end
        end

        if (found != 1) begin
            $display("FAIL: relay opened %0d times (expected exactly 1)", found);
            errors = errors + 1;
        end

        if (errors == 0) $display("=== ALL TESTS PASSED ===");
        else             $display("=== %0d TEST(S) FAILED ===", errors);

        $finish;
    end

endmodule
