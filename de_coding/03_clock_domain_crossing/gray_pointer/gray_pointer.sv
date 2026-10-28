// input is multiple bits
// only 1 bit change once, thus 1 bit may at metastability.
module gray_ptr_sync #(
    parameter int W = 4
) (
    input  logic         src_clk,
    input  logic         dst_clk,
    input  logic         src_rst_n,
    input  logic         dst_rst_n,
    input  logic [W-1:0] binary_i,
    output logic [W-1:0] gray_o
);

    logic [W-1:0] gray_src;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [W-1:0] meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [W-1:0] gray_dst;

    initial begin
        assert (W >= 2) else $fatal(1, "gray_ptr_sync: W must be >= 2");
    end

    // Encode and REGISTER in the source domain. A combinational converter
    // placed after the clock crossing can glitch as binary bits change.
    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) gray_src <= '0;
        else            gray_src <= binary_i ^ (binary_i >> 1);
    end

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            meta   <= '0;
            gray_dst <= '0;
        end
        else begin
            meta   <= gray_src;
            gray_dst <= meta;
        end
    end

    assign gray_o = gray_dst;

    // binary_i must be a src_clk pointer that advances by at most one per
    // source cycle, including wrap. W normally includes the extra FIFO wrap
    // bit. Constrain gray_src -> meta bus skew/max delay so bits from separate
    // updates cannot overlap in flight (usually within one source period).
    // The destination may skip intermediate Gray values; FIFO logic handles it.

endmodule
