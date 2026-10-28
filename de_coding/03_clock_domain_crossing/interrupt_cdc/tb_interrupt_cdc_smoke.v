`timescale 1ns/1ps
// Generated standalone smoke test for interrupt_cdc.
module tb_interrupt_cdc_smoke;
    reg src_clk;
    reg dst_clk;
    reg rst_n;
    reg irq_event;
    wire irq_ready;
    reg irq_clear;
    wire irq_pending;

    interrupt_cdc dut (
        .src_clk(src_clk),
        .dst_clk(dst_clk),
        .rst_n(rst_n),
        .irq_event(irq_event),
        .irq_ready(irq_ready),
        .irq_clear(irq_clear),
        .irq_pending(irq_pending)
    );
    always #5 src_clk = ~src_clk;
    always #7 dst_clk = ~dst_clk;

    integer cycle;
    integer errors;
    initial begin
        errors = 0;
        src_clk = 1'b0;
        dst_clk = 1'b0;
        rst_n = 1'b0;
        irq_event = 0;
        irq_clear = 0;
        cycle = 0;
        #20;
        rst_n = 1'b1;
        repeat (24) begin
            @(negedge src_clk);
            irq_event = $random;
            irq_clear = $random;
            #1;
            if ((^irq_ready) === 1'bx) begin $display("FAIL: interrupt_cdc.irq_ready is unknown at cycle %0d", cycle); errors = errors + 1; end
            if ((^irq_pending) === 1'bx) begin $display("FAIL: interrupt_cdc.irq_pending is unknown at cycle %0d", cycle); errors = errors + 1; end
            cycle = cycle + 1;
        end
        #10;
        if (errors != 0)
            $display("FAIL: interrupt_cdc reported %0d unknown outputs", errors);
        else
            $display("PASS: tb_interrupt_cdc_smoke completed %0d cycles", cycle);
        $finish;
    end
endmodule
