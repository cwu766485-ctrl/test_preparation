`timescale 1ns/1ps

module tb_secret_code;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg activate = 1'b0;
    reg [11:0] secret_code = 12'b0;

    wire [11:0] candidate_four;
    wire [11:0] candidate_single;
    wire busy_four, busy_single;
    wire relay_four, relay_single;

    integer errors = 0;
    integer cycles;
    integer i;

    secret_code_four four_m_dut (
        .clk(clk), .rst_n(rst_n), .activate(activate),
        .secret_code(secret_code), .candidate(candidate_four),
        .busy(busy_four), .relay_open(relay_four)
    );

    secret_code_single single_m_dut (
        .clk(clk), .rst_n(rst_n), .activate(activate),
        .secret_code(secret_code), .candidate(candidate_single),
        .busy(busy_single), .relay_open(relay_single)
    );

    always #5 clk = ~clk;

    task automatic compare_implementations;
        begin
            if (candidate_four !== candidate_single ||
                busy_four !== busy_single || relay_four !== relay_single) begin
                errors = errors + 1;
                $display("FAIL: four-M and single-M variants diverged at %0t", $time);
            end
        end
    endtask

    task automatic run_scan(input logic [11:0] code,
                            input integer expected_checks);
        begin
            @(negedge clk);
            secret_code = code;
            activate = 1'b1;
            @(posedge clk);
            #1;
            if (candidate_four !== 12'h000 || !busy_four || relay_four) begin
                errors = errors + 1;
                $display("FAIL: activate did not restart at 0000");
            end
            compare_implementations();

            // The target is sampled at activate. Changing the external bus
            // while searching must not change the code being searched for.
            @(negedge clk);
            activate = 1'b0;
            secret_code = ~code;

            cycles = 0;
            while (!relay_four && cycles < 4098) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
                compare_implementations();
            end

            if (cycles != expected_checks || !relay_four || busy_four ||
                candidate_four !== code) begin
                errors = errors + 1;
                $display("FAIL: code %04o checks=%0d expected=%0d candidate=%04o busy=%b relay=%b",
                         code, cycles, expected_checks, candidate_four,
                         busy_four, relay_four);
            end

            repeat (2) begin
                @(posedge clk);
                #1;
                compare_implementations();
                if (!relay_four || busy_four || candidate_four !== code) begin
                    errors = errors + 1;
                    $display("FAIL: relay/result did not hold after a match");
                end
            end
        end
    endtask

    initial begin
        $dumpfile("secretcode_search.vcd");
        $dumpvars(0, tb_secret_code);

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // 0000, the 7->10 octal carry boundary, a general code, and the
        // handwritten assignment example 11 4 5 (base-8: 12'o1145).
        run_scan(12'o0000, 1);
        run_scan(12'o0007, 8);
        run_scan(12'o0010, 9);
        run_scan(12'o0123, 84);
        run_scan(12'o1145, 614);

        // Restart a long search before it can finish; activate must reset all
        // four digit generators and capture the new secret code.
        @(negedge clk);
        secret_code = 12'o7777;
        activate = 1'b1;
        @(posedge clk);
        #1;
        @(negedge clk);
        activate = 1'b0;
        repeat (9) begin
            @(posedge clk);
            #1;
            compare_implementations();
        end
        run_scan(12'o0025, 22);

        // Asynchronous reset aborts a search and closes the relay immediately.
        @(negedge clk);
        secret_code = 12'o7777;
        activate = 1'b1;
        @(posedge clk);
        #1;
        @(negedge clk);
        activate = 1'b0;
        repeat (4) @(posedge clk);
        #1 rst_n = 1'b0;
        #1;
        if (busy_four || relay_four || candidate_four !== 12'h000) begin
            errors = errors + 1;
            $display("FAIL: asynchronous reset did not abort/clear the scan");
        end
        compare_implementations();
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // Highest code exercises all 12 carry bits and exactly 4096 candidates.
        run_scan(12'o7777, 4096);

        if (errors == 0)
            $display("PASS: secret-code search, four M blocks, single 12-bit counter, restart, and reset");
        else
            $fatal(1, "FAIL: secret-code test had %0d errors", errors);
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "FAIL: secret-code test timed out");
    end
endmodule
