// Counts source events modulo 2**COUNT_W, then transfers a Gray count.
// dst_delta reports how many events arrived since the previous destination
// sample. No event is lost IF fewer than 2**COUNT_W events occur between
// observed samples and the Gray bus-skew timing constraint is met.
module event_counter_cdc #(
    parameter int COUNT_W = 8
) (
    input  logic               src_clk,
    input  logic               dst_clk,
    input  logic               rst_n,
    input  logic               pulse_i,
    output logic [COUNT_W-1:0] dst_delta,
    output logic               dst_valid
);
    logic [COUNT_W-1:0] src_bin, src_gray;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [COUNT_W-1:0] gray_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [COUNT_W-1:0] gray_sync;
    logic [COUNT_W-1:0] dst_bin_prev;
    logic [COUNT_W-1:0] dst_bin_now;
    logic [COUNT_W-1:0] delta_now;

    initial begin
        assert (COUNT_W >= 2) else $fatal(1, "COUNT_W must be >= 2");
    end

    always_ff @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            src_bin  <= '0;
            src_gray <= '0;
        end else if (pulse_i) begin
            src_bin  <= src_bin + 1'b1;
            src_gray <= (src_bin + 1'b1) ^ ((src_bin + 1'b1) >> 1);
        end
    end

    always_ff @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            gray_meta <= '0;
            gray_sync <= '0;
            dst_bin_prev <= '0;
            dst_delta <= '0;
            dst_valid <= 1'b0;
        end else begin
            gray_meta <= src_gray;
            gray_sync <= gray_meta;
            dst_bin_prev <= dst_bin_now;
            dst_delta <= delta_now;
            dst_valid <= (delta_now != '0);
        end
    end

    always_comb begin
        dst_bin_now[COUNT_W-1] = gray_sync[COUNT_W-1];
        for (int i = COUNT_W-2; i >= 0; i--)
            dst_bin_now[i] = dst_bin_now[i+1] ^ gray_sync[i];
    end
    assign delta_now = dst_bin_now - dst_bin_prev;

    // pulse_i must be one src_clk cycle per event. If the source can create
    // multiple events in one cycle, use an event increment instead. Coordinate
    // resets: clearing one side alone can fabricate a huge delta.
endmodule
