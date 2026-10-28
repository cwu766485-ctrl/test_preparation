`timescale 1ns/1ps

module MatrixMultiplier_tb;
    reg CLK = 1'b0;
    reg NRST = 1'b0;
    reg START = 1'b0;
    reg signed [7:0] A = 8'sd0;
    reg signed [7:0] B = 8'sd0;
    wire signed [16:0] OUT;
    wire OUT_STROBE;

    integer fd;
    integer scan_count;
    integer a1, b1, a0, b0;
    integer expected;
    integer checked = 0;
    integer errors = 0;

    MatrixMultiplier dut (
        .CLK(CLK), .NRST(NRST), .START(START), .A(A), .B(B),
        .OUT(OUT), .OUT_STROBE(OUT_STROBE)
    );

    always #5 CLK = ~CLK;

    initial begin
        $dumpfile("MatrixMultiplier.vcd");
        $dumpvars(0, MatrixMultiplier_tb);

        repeat (2) @(negedge CLK);
        NRST = 1'b1;
        fd = $fopen("InputVector.txt", "r");
        if (fd == 0) $fatal(1, "Cannot open InputVector.txt");

        scan_count = $fscanf(fd, "%d %d %d %d", a1, b1, a0, b0);
        if (scan_count != 4) $fatal(1, "Malformed first row in InputVector.txt");

        // START begins a continuous stream. The first operands are sampled on
        // the following cycle, so the bus is free to carry A0/B0 next.
        @(negedge CLK);
        A = a1; B = b1; START = 1'b1;
        @(posedge CLK); #1;
        @(negedge CLK);
        START = 1'b0; A = a1; B = b1;

        while (scan_count == 4) begin
            @(posedge CLK); #1; // FIRST: capture A1*B1
            @(negedge CLK);
            A = a0; B = b0;
            expected = a1 * b1 + a0 * b0;
            @(posedge CLK); #1; // SECOND: OUT and OUT_STROBE

            if (OUT_STROBE !== 1'b1 || $signed(OUT) !== expected) begin
                errors = errors + 1;
                $display("FAIL row=%0d expected=%0d OUT=%0d strobe=%b",
                         checked, expected, $signed(OUT), OUT_STROBE);
            end else begin
                $display("PASS row=%0d result=%0d", checked, $signed(OUT));
            end
            checked = checked + 1;

            @(negedge CLK);
            scan_count = $fscanf(fd, "%d %d %d %d", a1, b1, a0, b0);
            if (scan_count == 4) begin
                A = a1; B = b1;
            end
        end
        $fclose(fd);

        if (checked != 8) begin
            errors = errors + 1;
            $display("FAIL expected 8 vectors, read %0d", checked);
        end

        // Strobe is a one-cycle valid pulse and reset aborts the stream.
        @(posedge CLK); #1;
        if (OUT_STROBE !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL OUT_STROBE did not return low");
        end
        #1 NRST = 1'b0;
        #1;
        if (OUT !== 17'sd0 || OUT_STROBE !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL asynchronous reset did not clear outputs");
        end

        if (errors == 0)
            $display("PASS: NM6008 signed matrix multiplier (%0d vectors)", checked);
        else
            $fatal(1, "FAIL: %0d matrix multiplier errors", errors);
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "FAIL: MatrixMultiplier_tb timeout");
    end
endmodule
