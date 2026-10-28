// Counts source events modulo 2**COUNT_W, then transfers a Gray count.
// dst_delta reports how many events arrived since the previous destination
// sample. No event is lost IF fewer than 2**COUNT_W events occur between
// observed samples and the Gray bus-skew timing constraint is met.


module event_counter_cdc #(
    parameter integer COUNT_W = 8
) (
    input wire src_clk,
    input wire dst_clk,
    input wire rst_n,
    input wire pulse_i,
    output reg [COUNT_W-1:0] dst_delta,
    output reg dst_valid
);
    integer i;
    reg [COUNT_W-1:0] src_bin, src_gray;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [COUNT_W-1:0] gray_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [COUNT_W-1:0] gray_sync;
    reg [COUNT_W-1:0] dst_bin_prev;
    reg [COUNT_W-1:0] dst_bin_now;
    wire [COUNT_W-1:0] delta_now;

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    always @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            src_bin  <= 0;
            src_gray <= 0;
        end else if (pulse_i) begin
            src_bin  <= src_bin + 1'b1;
            src_gray <= (src_bin + 1'b1) ^ ((src_bin + 1'b1) >> 1);
        end
    end

    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            gray_meta <= 0;
            gray_sync <= 0;
            dst_bin_prev <= 0;
            dst_delta <= 0;
            dst_valid <= 1'b0;
        end else begin
            gray_meta <= src_gray;
            gray_sync <= gray_meta;
            dst_bin_prev <= dst_bin_now;
            dst_delta <= delta_now;
            dst_valid <= (delta_now != 0);
        end
    end

    always @* begin
        dst_bin_now[COUNT_W-1] = gray_sync[COUNT_W-1];
        for (i = COUNT_W-2; i >= 0; i = i - 1)
            dst_bin_now[i] = dst_bin_now[i+1] ^ gray_sync[i];
    end
    assign delta_now = dst_bin_now - dst_bin_prev;

    // pulse_i must be one src_clk cycle per event. If the source can create
    // multiple events in one cycle, use an event increment instead. Coordinate
    // resets: clearing one side alone can fabricate a huge delta.
endmodule