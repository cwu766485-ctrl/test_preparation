`timescale 1ns/1ps
// Generated standalone smoke test for uart_rx.
module tb_uart_rx_smoke;
    localparam integer BAUD_CNT = 16;
    reg clk;
    reg rst_n;
    reg rx;
    wire [7:0] data_out;
    wire data_valid;

    uart_rx dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );
    always #5 clk = ~clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        clk = 1'b0;
        rst_n = 1'b0;
        rx = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge clk);
            rx = $random;
            #1;
            if ((^data_out) === 1'bx) begin $display("FAIL: uart_rx.data_out is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^data_valid) === 1'bx) begin $display("FAIL: uart_rx.data_valid is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: uart_rx reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_uart_rx_smoke completed %0d cycles", cycle);
        $finish;
    end
    initial begin
        $dumpfile("uart_rx_tb_uart_rx_smoke.vcd");
        $dumpvars(0, tb_uart_rx_smoke);
    end

endmodule
