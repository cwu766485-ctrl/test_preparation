`timescale 1ns/1ps
// Generated standalone smoke test for handshake_master.
module tb_handshake_master_smoke;
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] data;
    reg ack;
    wire req;
    wire [7:0] data_out;
    wire done;

    handshake_master dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data(data),
        .ack(ack),
        .req(req),
        .data_out(data_out),
        .done(done)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        start = 0;
        data = 0;
        ack = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            start = $random;
            data = $random;
            ack = $random;
            #1;
            if ((^req) === 1'bx) begin $display("FAIL: handshake_master.req is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^data_out) === 1'bx) begin $display("FAIL: handshake_master.data_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^done) === 1'bx) begin $display("FAIL: handshake_master.done is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: handshake_master reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_handshake_master_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
