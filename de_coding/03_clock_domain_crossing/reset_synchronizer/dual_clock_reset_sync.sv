// Example wrapper for two unrelated clock domains.
// Both local resets assert immediately with async_rst_n, but each reset
// deasserts only on the active edge of its own clock.
module dual_clock_reset_sync #(
    parameter int STAGES = 2
) (
    input  logic src_clk,
    input  logic dst_clk,
    input  logic async_rst_n,
    output logic src_rst_n,
    output logic dst_rst_n
);

    reset_synchronizer #(
        .STAGES(STAGES)
    ) u_src_reset_sync (
        .clk        (src_clk),
        .async_rst_n(async_rst_n),
        .sync_rst_n (src_rst_n)
    );

    reset_synchronizer #(
        .STAGES(STAGES)
    ) u_dst_reset_sync (
        .clk        (dst_clk),
        .async_rst_n(async_rst_n),
        .sync_rst_n (dst_rst_n)
    );

endmodule
