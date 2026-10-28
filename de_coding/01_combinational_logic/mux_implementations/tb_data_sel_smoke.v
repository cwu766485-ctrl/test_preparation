`timescale 1ns/1ps
// Generated standalone smoke test for data_sel.
module tb_data_sel_smoke;
    reg S0;
    reg S1;
    reg D0;
    reg D1;
    reg D2;
    reg D3;
    wire Y;

    data_sel dut (
        .S0(S0),
        .S1(S1),
        .D0(D0),
        .D1(D1),
        .D2(D2),
        .D3(D3),
        .Y(Y)
    );

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        S0 = 0;
        S1 = 0;
        D0 = 0;
        D1 = 0;
        D2 = 0;
        D3 = 0;
        cycle = 0;
        #20;
        repeat (24) begin
            #5;
            S0 = $random;
            S1 = $random;
            D0 = $random;
            D1 = $random;
            D2 = $random;
            D3 = $random;
            #1;
            if ((^Y) === 1'bx) begin $display("FAIL: data_sel.Y is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: data_sel reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_data_sel_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("mux_implementations_tb_data_sel_smoke.vcd");
        $dumpvars(0, tb_data_sel_smoke);
    end

endmodule
