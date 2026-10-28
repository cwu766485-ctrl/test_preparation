

module pulse_sync (
    input wire src_clk,
    input wire dst_clk,
    input wire rst_n,
    input wire pulse_i,
    output wire pulse_o
);

    reg toggle_src;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg sync_1;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg sync_2;
    reg sync_2_d;

    always @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            toggle_src <= 1'b0;
        end
        else if (pulse_i) begin
            toggle_src <= ~toggle_src;
        end
    end
/*
源域每收到一次脉冲，就翻转一次状态：
初始：0
第 1 次 pulse：1
第 2 次 pulse：0
第 3 次 pulse：1
*/
    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_1   <= 1'b0;
            sync_2   <= 1'b0;
            sync_2_d <= 1'b0;
        end
        else begin
            sync_1   <= toggle_src;
            sync_2   <= sync_1;
            sync_2_d <= sync_2;
        end
    end

    assign pulse_o = sync_2 ^ sync_2_d;

    // Open-loop toggle: two pulses that toggle twice before dst_clk observes
    // the intermediate state cancel each other. For guaranteed events use
    // pulse_handshake; for counted bursts use event_counter_cdc. Both domains
    // must share a coordinated reset to avoid a false transition on restart.

endmodule