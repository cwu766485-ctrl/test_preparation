`timescale 1ns/1ps
// NM6008 SELF-CHECKING TB TEMPLATE
// One TB serves RTL simulation and gate-level SDF simulation.
module tb_ExamDUT;

    // [1] EDIT-TB-1: Declare DUT interface signals, widths and directions.
    reg        CLK;
    reg        NRST;
    reg        START;
    reg  [7:0] A, B;
    wire [8:0] RESULT;
    wire       DONE;
    integer    checks, errors;

    // [2] EDIT-TB-2: DUT instance name "dut" must match SDF and SAIF paths.
    ExamDUT dut (
        .CLK(CLK), .NRST(NRST), .START(START),
        .A(A), .B(B), .RESULT(RESULT), .DONE(DONE)
    );

    // [3] EDIT-TB-3: CLK period = 2 * 50 ns = 100 ns.
    initial CLK = 1'b0;
    always #50 CLK = ~CLK;

    // [4] Tasks: independent checking, reset sequence, and one transaction.
    task automatic check_outputs;
        input [8:0] expected_result;
        input       expected_done;
        begin
            checks = checks + 1;
            if (RESULT !== expected_result || DONE !== expected_done) begin
                errors = errors + 1;
                $display("FAIL t=%0t RESULT=%h DONE=%b expected=%h/%b",
                         $time, RESULT, DONE, expected_result, expected_done);
            end else begin
                $display("PASS t=%0t RESULT=%h DONE=%b", $time, RESULT, DONE);
            end
        end
    endtask

    task automatic apply_reset;
        begin
            // EDIT-TB-4: Adapt reset polarity and sync/async timing to the spec.
            NRST = 1'b0;
            START = 1'b0;
            A = 8'd0;
            B = 8'd0;
            repeat (2) @(posedge CLK);
            #20;
            check_outputs(9'd0, 1'b0);
            @(negedge CLK);
            NRST = 1'b1;
        end
    endtask

    task automatic run_case;
        input [7:0] a_in;
        input [7:0] b_in;
        reg   [8:0] expected_sum;
        begin
            // EDIT-TB-5: Reference model MUST reflect the exam specification.
            expected_sum = {1'b0, a_in} + {1'b0, b_in};

            // Drive on falling edge to avoid racing the DUT's rising edge.
            @(negedge CLK);
            A = a_in;
            B = b_in;
            START = 1'b1;

            @(posedge CLK);
            #20; // Allow NBA and SDF propagation; adjust after timing review.
            check_outputs(expected_sum, 1'b1);

            // Confirm DONE drops after one cycle and RESULT holds.
            @(negedge CLK);
            START = 1'b0;
            @(posedge CLK);
            #20;
            check_outputs(expected_sum, 1'b0);
        end
    endtask

    // [5] Gate-level SDF ONLY: leave unchanged in RTL simulation.
`ifdef GATE_SIM
    initial begin
        // EDIT-TB-6: SDF filename and the instance "dut" must be correct.
        $sdf_annotate("Syn_ExamDUT.sdf", dut);
    end
`endif

    // [6] Save waveforms for BOTH modes (Synopsys VCS VPD format).
    initial begin
        $vcdplusfile("inter.vpd");
        $vcdpluson(0, tb_ExamDUT);
    end

    // [7] Main test flow: initial values -> reset -> directed tests -> finish.
    initial begin
        checks = 0;
        errors = 0;
        NRST   = 1'b0;
        START  = 1'b0;
        A      = 8'd0;
        B      = 8'd0;

        apply_reset();

        // EDIT-TB-7: Replace/add cases based on the exam specification.
        run_case(8'd0,   8'd0);   // zero
        run_case(8'd1,   8'd2);   // simple
        run_case(8'd255, 8'd1);   // carry-out: expected 9'h100
        run_case(8'd255, 8'd255); // maximum
        run_case(8'd170, 8'd85);  // alternating bits

        $display("SUMMARY checks=%0d errors=%0d", checks, errors);
        $vcdplusoff;
        if (errors == 0) begin
            $display("TEST PASS: %0d checks", checks);
            $finish;
        end else begin
            $fatal(1, "TEST FAIL: %0d errors", errors);
        end
    end

    // [8] Timeout: fail instead of hanging forever.
    initial begin
        #100000;
        $fatal(1, "TIMEOUT");
    end
endmodule
