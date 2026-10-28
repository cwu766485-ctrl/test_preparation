
`timescale 1ns/1ps

module tb_traffic_mealy;

    logic clk = 0;
    always #5 clk = ~clk;

    logic rst_n = 1;
    logic start = 0;
    wire [1:0] out;

    localparam logic [1:0]
        IDLE = 2'b00,
        RUN  = 2'b01,
        DONE = 2'b10;

    logic [1:0] model_state = IDLE;

    int checks = 0;
    int seen_idle = 0;
    int seen_run  = 0;
    int seen_done = 0;

    traffic_fsm_mealy dut (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .out   (out)
    );

    // Independent output reference
    function automatic logic [1:0] ref_output(
        input logic [1:0] s,
        input bit st,
        input bit reset_n
    );
        if (!reset_n)
            return 2'b00;

        case (s)
            IDLE: return st ? 2'b01 : 2'b00;
            RUN:  return 2'b01;
            DONE: return 2'b10;
            default: return 2'b00;
        endcase
    endfunction

    task automatic check_output(input string tag);
        logic [1:0] expected;

        expected = ref_output(
            model_state, start, rst_n
        );

        if (out !== expected)
            $fatal(1,
                "%s FAIL: state=%b start=%b exp=%b got=%b",
                tag, model_state, start, expected, out);
    endtask

    // Asynchronous reset
    task automatic reset_dut;
        @(negedge clk);

        rst_n = 0;
        start = 0;
        model_state = IDLE;

        #1;
        check_output("RESET");

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst_n = 1;

        #1;
        check_output("RELEASE RESET");
    endtask

    task automatic step(input bit start_value);

        @(negedge clk);
        start = start_value;

        // Important:
        // Check Mealy output BEFORE posedge
        #1;
        check_output("PRE-EDGE");

        // Predict next state
        @(posedge clk);

        case (model_state)
            IDLE: begin
                if (start_value)
                    model_state = RUN;
            end

            RUN:  model_state = DONE;
            DONE: model_state = IDLE;
            default: model_state = IDLE;
        endcase

        // Wait for DUT NBA updates
        #1;
        check_output("POST-EDGE");

        case (model_state)
            IDLE: seen_idle++;
            RUN:  seen_run++;
            DONE: seen_done++;
        endcase

        checks++;

        $display(
            "PASS check=%0d start=%b model_state=%b out=%b",
            checks, start_value, model_state, out
        );
    endtask

    initial begin
        $dumpfile("traffic_mealy.vcd");
        $dumpvars(0, tb_traffic_mealy);

        reset_dut();

        // TP01: IDLE hold
        repeat (3)
            step(0);

        // TP02: Start transition
        step(1);

        // TP03: RUN -> DONE -> IDLE
        step(0);
        step(0);

        // TP04: Continuous start
        repeat (9)
            step(1);

        // TP05: Random start
        for (int i = 0; i < 100; i++)
            step($urandom_range(0, 1));

        // TP06: Reset while RUN
        reset_dut();
        step(1);
        reset_dut();

        // TP07: Resume after reset
        step(1);
        step(0);
        step(0);

        // Check all states were visited
        if (seen_idle == 0 ||
            seen_run  == 0 ||
            seen_done == 0)
            $fatal(1, "STATE COVERAGE FAIL");

        $display(
            "MEALY FSM ALL TESTS PASSED: %0d checks",
            checks
        );

        $finish;
    end

endmodule
