`timescale 1ns/1ps
// Generated standalone smoke test for prio_encoder.
module tb_prio_encoder_smoke;
    reg [7:0] req;
    wire [2:0] enc;
    wire valid;

    prio_encoder dut (
        .req(req),
        .enc(enc),
        .valid(valid)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        req = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            req = $random;
            #1;
            if ((^enc) === 1'bx) begin $display("FAIL: prio_encoder.enc is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^valid) === 1'bx) begin $display("FAIL: prio_encoder.valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: prio_encoder reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_prio_encoder_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
