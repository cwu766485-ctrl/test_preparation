
`timescale 1ns/1ps

module FullAdder_tb;

    reg A, B, CIN;
    wire S, COUT;

    integer i, j, count, errors, k;
    integer n_max_S, n_max_C;

    reg [2:0] present_inputs;
    reg [2:0] next_inputs;

    reg [2:0] max_S_from [0:55];
    reg [2:0] max_S_to   [0:55];
    reg [2:0] max_C_from [0:55];
    reg [2:0] max_C_to   [0:55];

    reg expected_S, expected_COUT;
    reg old_S, old_COUT;
    reg measuring;

    real input_time;
    real last_S_time;
    real last_COUT_time;

    real delay_S;
    real delay_COUT;
    real max_S;
    real max_COUT;

    integer fd;

    FullAdder U1 (
        .A(A),
        .B(B),
        .CIN(CIN),
        .S(S),
        .COUT(COUT)
    );

    initial begin
        $sdf_annotate("Syn_FullAdder.sdf", U1);
    end

    // Record output transitions with ps precision.
    always @(S) begin
        if (measuring)
            last_S_time = $realtime;
    end

    always @(COUT) begin
        if (measuring)
            last_COUT_time = $realtime;
    end

    initial begin
        $vcdpluson(U1);

        fd = $fopen("critical_delay_results.txt", "w");

        count = 0;
        errors = 0;
        max_S = -1.0;
        max_COUT = -1.0;
        n_max_S = 0;
        n_max_C = 0;
        measuring = 0;

        {A, B, CIN} = 3'b000;

        $display("Full-Adder 56-Transition Analysis");
        $fdisplay(fd,
            "No. Present Next S_delay(ps) COUT_delay(ps)");

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin

                if (i != j) begin

                    count = count + 1;
                    present_inputs = i;
                    next_inputs = j;

                    // Apply present input pattern.
                    measuring = 0;
                    {A, B, CIN} = present_inputs;
                    #10;

                    old_S = S;
                    old_COUT = COUT;

                    expected_S =
                        next_inputs[2] ^
                        next_inputs[1] ^
                        next_inputs[0];

                    expected_COUT =
                        (next_inputs[2] & next_inputs[1]) |
                        (next_inputs[2] & next_inputs[0]) |
                        (next_inputs[1] & next_inputs[0]);

                    last_S_time = -1.0;
                    last_COUT_time = -1.0;

                    input_time = $realtime;
                    measuring = 1;

                    {A, B, CIN} = next_inputs;

                    // Allow outputs to settle.
                    #10;
                    measuring = 0;

                    delay_S = -1.0;
                    delay_COUT = -1.0;

                    // Only report propagation delay if
                    // the final output differs from the
                    // previous stable output.
                    if (old_S !== expected_S &&
                        last_S_time >= 0.0)
                        delay_S =
                            (last_S_time - input_time) * 1000.0;

                    if (old_COUT !== expected_COUT &&
                        last_COUT_time >= 0.0)
                        delay_COUT =
                            (last_COUT_time - input_time) * 1000.0;

                    if (S !== expected_S ||
                        COUT !== expected_COUT) begin
                        errors = errors + 1;
                        $display("FUNCTIONAL ERROR: %03b -> %03b",
                                 present_inputs, next_inputs);
                    end

                    if (delay_S > max_S) begin
                        max_S = delay_S;
                        n_max_S = 0;
                    end

                    if (delay_S >= 0.0 &&
                        delay_S == max_S) begin
                        max_S_from[n_max_S] = present_inputs;
                        max_S_to[n_max_S] = next_inputs;
                        n_max_S = n_max_S + 1;
                    end

                    if (delay_COUT > max_COUT) begin
                        max_COUT = delay_COUT;
                        n_max_C = 0;
                    end

                    if (delay_COUT >= 0.0 &&
                        delay_COUT == max_COUT) begin
                        max_C_from[n_max_C] = present_inputs;
                        max_C_to[n_max_C] = next_inputs;
                        n_max_C = n_max_C + 1;
                    end

                    $display(
                      "%2d: %03b -> %03b | S=%0.1f ps | COUT=%0.1f ps",
                      count, present_inputs, next_inputs,
                      delay_S, delay_COUT
                    );

                    $fdisplay(fd,
                      "%2d: %03b -> %03b | S=%0.1f ps | COUT=%0.1f ps",
                      count, present_inputs, next_inputs,
                      delay_S, delay_COUT
                    );

                end
            end
        end

        $display("\n========== FINAL RESULTS ==========");
        $display("Total transitions: %0d", count);
        $display("Functional errors: %0d", errors);

        $display("\nMaximum S delay: %0.1f ps", max_S);
        $fdisplay(fd, "\nMaximum S delay: %0.1f ps", max_S);

        for (k = 0; k < n_max_S; k = k + 1) begin
            $display("S: %03b -> %03b",
                max_S_from[k], max_S_to[k]);
            $fdisplay(fd, "S: %03b -> %03b",
                max_S_from[k], max_S_to[k]);
        end

        $display("\nMaximum COUT delay: %0.1f ps", max_COUT);
        $fdisplay(fd,
            "\nMaximum COUT delay: %0.1f ps", max_COUT);

        for (k = 0; k < n_max_C; k = k + 1) begin
            $display("COUT: %03b -> %03b",
                max_C_from[k], max_C_to[k]);
            $fdisplay(fd, "COUT: %03b -> %03b",
                max_C_from[k], max_C_to[k]);
        end

        $fclose(fd);
        $finish;
    end

endmodule

