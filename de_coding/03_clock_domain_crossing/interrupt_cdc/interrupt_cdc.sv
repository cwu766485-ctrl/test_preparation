// Event interrupt crossing. Source accepts irq_event only while irq_ready=1;
// the destination latches it until software/peripheral logic asserts irq_clear.
// Multiple accepted events coalesce into one pending interrupt. For per-event
// accounting use event_counter_cdc or an asynchronous FIFO instead.
module interrupt_cdc (
    input  logic src_clk,
    input  logic dst_clk,
    input  logic rst_n,
    input  logic irq_event,
    output logic irq_ready,
    input  logic irq_clear,
    output logic irq_pending
);
    logic irq_arrived;

    pulse_handshake u_cross (
        .src_clk(src_clk), .dst_clk(dst_clk), .rst_n(rst_n),
        .pulse_i(irq_event), .src_ready(irq_ready), .pulse_o(irq_arrived)
    );

    always_ff @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n)
            irq_pending <= 1'b0;
        else if (irq_arrived)
            irq_pending <= 1'b1; // new event wins over simultaneous clear
        else if (irq_clear)
            irq_pending <= 1'b0;
    end
endmodule
