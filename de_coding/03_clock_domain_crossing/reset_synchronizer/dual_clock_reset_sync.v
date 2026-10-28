// Example wrapper for two unrelated clock domains.
// Both local resets assert immediately with async_rst_n, but each reset
// deasserts only on the active edge of its own clock.


module dual_clock_reset_sync #(
    parameter integer STAGES = 2
) (
    input wire src_clk,
    input wire dst_clk,
    input wire async_rst_n,
    output wire src_rst_n,
    output wire dst_rst_n
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