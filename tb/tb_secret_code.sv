`timescale 1ns/1ps
module tb_secret_code;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic activate = 1'b0;
    logic [11:0] secret_code = 12'd0;

    wire [11:0] four_candidate, single_candidate;
    wire [3:0] four_match, single_match;
    wire four_busy, single_busy, four_relay, single_relay;
    integer checked_cycles = 0;

    always #5 clk = ~clk;

    secret_code_four dut_four (
        .clk(clk), .rst_n(rst_n), .activate(activate),
        .secret_code(secret_code), .candidate(four_candidate),
        .match_bits(four_match), .busy(four_busy), .relay_open(four_relay)
    );
    secret_code_single dut_single (
        .clk(clk), .rst_n(rst_n), .activate(activate),
        .secret_code(secret_code), .candidate(single_candidate),
        .match_bits(single_match), .busy(single_busy),
        .relay_open(single_relay)
    );

    initial begin
`ifdef VCS_VPD
        $vcdpluson(0, tb_secret_code);
`else
        $dumpfile("secret_code_rtl.vcd");
        $dumpvars(0, tb_secret_code);
`endif
    end

    task automatic check_state(
        input logic [11:0] exp_candidate,
        input logic exp_busy,
        input logic exp_relay
    );
        logic [3:0] exp_match;
        begin
            exp_match[3] = (exp_candidate[11:9] == secret_code[11:9]);
            exp_match[2] = (exp_candidate[8:6]  == secret_code[8:6]);
            exp_match[1] = (exp_candidate[5:3]  == secret_code[5:3]);
            exp_match[0] = (exp_candidate[2:0]  == secret_code[2:0]);
            if (four_candidate !== exp_candidate ||
                four_busy !== exp_busy || four_relay !== exp_relay ||
                four_match !== exp_match)
                $fatal(1, "FOUR failed t=%0t exp=%03h/%b/%b/%b got=%03h/%b/%b/%b",
                       $time, exp_candidate, exp_busy, exp_relay, exp_match,
                       four_candidate, four_busy, four_relay, four_match);
            if (single_candidate !== exp_candidate ||
                single_busy !== exp_busy || single_relay !== exp_relay ||
                single_match !== exp_match)
                $fatal(1, "SINGLE failed t=%0t exp=%03h/%b/%b/%b got=%03h/%b/%b/%b",
                       $time, exp_candidate, exp_busy, exp_relay, exp_match,
                       single_candidate, single_busy, single_relay, single_match);
            checked_cycles++;
        end
    endtask

    task automatic run_case(input logic [11:0] target);
        integer k;
        begin
            @(negedge clk);
            secret_code = target;
            activate = 1'b1;
            @(posedge clk); #1;
            check_state(12'd0, 1'b1, 1'b0);
            @(negedge clk);
            activate = 1'b0;

            // Independent golden-model enumeration: candidate starts 0,
            // then advances until target and latches the relay on next edge.
            for (k = 0; k <= int'(target); k++) begin
                @(posedge clk); #1;
                if (k == int'(target))
                    check_state(target, 1'b0, 1'b1);
                else
                    check_state(12'(k + 1), 1'b1, 1'b0);
            end
            repeat (3) begin
                @(posedge clk); #1;
                check_state(target, 1'b0, 1'b1);
            end
            $display("PASS target=%04o cycles_to_open=%0d",
                     target, int'(target) + 1);
        end
    endtask

    initial begin : main_test
        @(posedge clk); #1;
        check_state(12'd0, 1'b0, 1'b0);
        @(negedge clk);
        rst_n = 1'b1;

        // Zero, first nonzero, partial matches, example code, max, mixed.
        run_case(12'o0000);
        run_case(12'o0001);
        run_case(12'o1145);
        run_case(12'o7777);
        run_case(12'o0707);

        // Restart while BUSY; new start must reset candidate and relay.
        @(negedge clk);
        secret_code = 12'o7777; activate = 1'b1;
        @(posedge clk); #1; check_state(12'd0, 1'b1, 1'b0);
        @(negedge clk); activate = 1'b0;
        repeat (12) @(posedge clk);
        #1;
        check_state(12'd12, 1'b1, 1'b0);
        @(negedge clk);
        secret_code = 12'o0004; activate = 1'b1;
        @(posedge clk); #1; check_state(12'd0, 1'b1, 1'b0);
        @(negedge clk); activate = 1'b0;
        @(posedge clk); #1; check_state(12'd1, 1'b1, 1'b0);
        // candidate is 1 now; advance through 2,3,4, then latch.
        @(posedge clk); #1; check_state(12'd2, 1'b1, 1'b0);
        @(posedge clk); #1; check_state(12'd3, 1'b1, 1'b0);
        @(posedge clk); #1; check_state(12'd4, 1'b1, 1'b0);
        @(posedge clk); #1; check_state(12'd4, 1'b0, 1'b1);

        // Async reset clears both architectures without a clock edge.
        @(negedge clk); #1; rst_n = 1'b0; #1;
        check_state(12'd0, 1'b0, 1'b0);
        repeat (2) @(posedge clk);
        @(negedge clk); rst_n = 1'b1;
        @(posedge clk); #1;
        check_state(12'd0, 1'b0, 1'b0);

        $display("PASS ALL: %0d self-checked samples", checked_cycles);
        $finish;
    end

    initial begin
        #150000;
        $fatal(1, "TIMEOUT");
    end
endmodule
