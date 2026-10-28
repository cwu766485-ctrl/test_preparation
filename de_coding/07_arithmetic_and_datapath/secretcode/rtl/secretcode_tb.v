module secretcode_tb;
    reg clk;
    reg rst_n;
    reg digit_valid;
    reg [3:0] digit;
    reg relock;
    wire unlocked;
    wire locked_out;
    wire error_pulse;
    integer errors;
    integer i;

    secretcode dut (
        .clk(clk),
        .rst_n(rst_n),
        .digit_valid(digit_valid),
        .digit(digit),
        .relock(relock),
        .unlocked(unlocked),
        .locked_out(locked_out),
        .error_pulse(error_pulse)
    );

    always #5 clk = ~clk;

    initial $sdf_annotate("Syn_secretcode.sdf", dut);

    task check_outputs;
        input [2:0] expected;
        begin
            #1;
            if ({unlocked, locked_out, error_pulse} !== expected) begin
                errors = errors + 1;
                $display("FAIL outputs=%b expected=%b at %0t",
                         {unlocked, locked_out, error_pulse}, expected, $time);
            end
        end
    endtask

    task send_digit;
        input [3:0] value;
        input expected_error;
        begin
            @(negedge clk);
            digit = value;
            digit_valid = 1'b1;
            @(posedge clk);
            #1;
            if (error_pulse !== expected_error) begin
                errors = errors + 1;
                $display("FAIL digit=%0d error_pulse=%b expected=%b at %0t",
                         value, error_pulse, expected_error, $time);
            end
            @(negedge clk);
            digit_valid = 1'b0;
        end
    endtask

    task enter_password;
        begin
            send_digit(4'd0, 1'b0);
            send_digit(4'd1, 1'b0);
            send_digit(4'd2, 1'b0);
            send_digit(4'd4, 1'b0);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        digit_valid = 1'b0;
        digit = 4'd0;
        relock = 1'b0;
        errors = 0;

        #1;
        check_outputs(3'b000);
        @(negedge clk);
        rst_n = 1'b1;

        enter_password();
        check_outputs(3'b100);

        @(negedge clk);
        relock = 1'b1;
        @(posedge clk);
        check_outputs(3'b000);
        @(negedge clk);
        relock = 1'b0;

        for (i = 0; i < 5; i = i + 1) begin
            send_digit(4'd9, 1'b1);
            if (i == 4) check_outputs(3'b011);
            else        check_outputs(3'b001);
        end

        // A locked controller ignores further valid digits until reset.
        enter_password();
        check_outputs(3'b010);

        // Reset is asynchronous and clears both the lock and error pulse.
        rst_n = 1'b0;
        check_outputs(3'b000);
        @(negedge clk);
        rst_n = 1'b1;
        enter_password();
        check_outputs(3'b100);

        if (errors == 0) $display("PASS: secretcode reset, unlock, relock, and lockout");
        else             $fatal(1, "FAIL: secretcode test had %0d errors", errors);
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "FAIL: secretcode test timeout");
    end
    initial begin
        $dumpfile("rtl_secretcode_tb.vcd");
        $dumpvars(0, secretcode_tb);
    end

endmodule
