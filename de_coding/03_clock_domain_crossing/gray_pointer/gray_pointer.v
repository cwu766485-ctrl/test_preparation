// input is multiple bits
// only 1 bit change once, thus 1 bit may at metastability.


module gray_ptr_sync #(
    parameter integer W = 4
) (
    input wire src_clk,
    input wire dst_clk,
    input wire src_rst_n,
    input wire dst_rst_n,
    input wire [W-1:0] binary_i,
    output wire [W-1:0] gray_o
);

    reg [W-1:0] gray_src;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [W-1:0] meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [W-1:0] gray_dst;

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    // Encode and REGISTER in the source domain. A combinational converter
    // placed after the clock crossing can glitch as binary bits change.
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) gray_src <= 0;
        else            gray_src <= binary_i ^ (binary_i >> 1);
    end

    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            meta   <= 0;
            gray_dst <= 0;
        end
        else begin
            meta   <= gray_src;
            gray_dst <= meta;
        end
    end

    assign gray_o = gray_dst;

    // binary_i must be a src_clk pointer that advances by at most one per
    // source cycle, including wrap. W normally includes the extra FIFO wrap
    // reg. Constrain gray_src -> meta bus skew/max delay so bits from separate
    // updates cannot overlap in flight (usually within one source period).
    // The destination may skip intermediate Gray values; FIFO reg handles it.

endmodule