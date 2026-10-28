
`timescale 1ns/1ps

module FullAdder_tb;

    reg A, B, CIN;
    wire S, COUT;

    integer i, j;

    reg [2:0] present_inputs;
    reg [2:0] next_inputs;

    // Instantiate synthesized full-adder
    FullAdder U1 (
        .A(A),
        .B(B),
        .CIN(CIN),
        .S(S),
        .COUT(COUT)
    );

    initial begin
        // Annotate gate-level delays
        $sdf_annotate("Syn_FullAdder.sdf", U1);
    end

    initial begin
        $vcdpluson(U1);

        A = 0;
        B = 0;
        CIN = 0;

        // Test all 56 directed transitions
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin

                if (i != j) begin

                    present_inputs = i;
                    next_inputs = j;

                    // Apply present input combination
                    {A, B, CIN} = present_inputs;
                    #10;

                    // Apply next input combination
                    {A, B, CIN} = next_inputs;

                    $display(
                        "Time=%0t ps: %03b -> %03b",
                        $time, present_inputs, next_inputs
                    );

                    // Allow output to settle
                    #10;
                end

            end
        end

        $finish;
    end

endmodule

