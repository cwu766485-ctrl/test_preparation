// Educational glitch-free clock mux: disable the active clock on its falling
// edge before enabling the other. A switch can pause clk_out for several
// cycles. Both input clocks MUST keep running; use a library clock mux cell
// for production clock trees and follow its STA/CTS constraints.
module glitch_free_clock_switch (
    input  logic clk0,
    input  logic clk1,
    input  logic sel_async,
    input  logic rst_n,
    output logic clk_out
);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [1:0] sel0_sync;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [1:0] sel1_sync;
    logic en0, en1;

    always_ff @(posedge clk0 or negedge rst_n) begin
        if (!rst_n) sel0_sync <= '0;
        else        sel0_sync <= {sel0_sync[0], sel_async};
    end
    always_ff @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) sel1_sync <= '0;
        else        sel1_sync <= {sel1_sync[0], sel_async};
    end

    always_ff @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) en0 <= 1'b0;
        else        en0 <= !sel0_sync[1] && !en1;
    end
    always_ff @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) en1 <= 1'b0;
        else        en1 <= sel1_sync[1] && !en0;
    end

    assign clk_out = (clk0 && en0) || (clk1 && en1);
    // en0/en1 must be implemented as clock-gating safe logic. Generic RTL
    // synthesis alone does not certify a glitch-free physical clock tree.
endmodule

// More explicit RTL model with an always-running control clock.
// ctrl_clk owns the switch decision; each source clock only changes its gate
// on its falling edge. The controller waits for feedback that the old gate is
// actually off before requesting the new gate. This avoids directly sampling
// en0 in clk1 logic (and en1 in clk0 logic).
//
// ctrl_clk, clk0 and clk1 must all be free-running during a switch. If a source
// clock can stop, use the library's integrated glitch-free clock mux cell.
module glitch_free_clock_switch_ownership (
    input  logic ctrl_clk,
    input  logic clk0,
    input  logic clk1,
    input  logic sel_async,
    input  logic rst_n,
    output logic clk_out
);
    typedef enum logic [2:0] {S_IDLE, S_RUN0, S_RUN1,
                              S_WAIT_OFF0, S_WAIT_OFF1} state_t;
    state_t state, state_n;
    logic sel_c1, sel_c2;
    logic req0, req1;
    logic req0_c1, req0_c2, req1_c1, req1_c2;
    logic en0, en1;
    logic en0_c1, en0_c2, en1_c1, en1_c2;

    // Selection enters the always-running controller domain.
    (* ASYNC_REG = "TRUE" *) logic sel_meta;
    always_ff @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_meta <= 1'b0;
            sel_c1   <= 1'b0;
            sel_c2   <= 1'b0;
        end else begin
            sel_meta <= sel_async;
            sel_c1   <= sel_meta;
            sel_c2   <= sel_c1;
        end
    end

    // Controller feedback: the gate enables are synchronized back to ctrl_clk.
    always_ff @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n) begin
            en0_c1 <= 1'b0; en0_c2 <= 1'b0;
            en1_c1 <= 1'b0; en1_c2 <= 1'b0;
        end else begin
            en0_c1 <= en0; en0_c2 <= en0_c1;
            en1_c1 <= en1; en1_c2 <= en1_c1;
        end
    end

    always_comb begin
        state_n = state;
        req0 = 1'b0;
        req1 = 1'b0;
        case (state)
            S_IDLE: begin
                if (sel_c2) state_n = S_WAIT_OFF0;
                else        state_n = S_WAIT_OFF1;
            end
            S_RUN0: begin
                req0 = 1'b1;
                if (sel_c2) state_n = S_WAIT_OFF0;
            end
            S_RUN1: begin
                req1 = 1'b1;
                if (!sel_c2) state_n = S_WAIT_OFF1;
            end
            S_WAIT_OFF0: begin
                // Request clk0 off; only after feedback is low may clk1 open.
                if (!en0_c2) state_n = S_RUN1;
            end
            S_WAIT_OFF1: begin
                // Request clk1 off; only after feedback is low may clk0 open.
                if (!en1_c2) state_n = S_RUN0;
            end
            default: state_n = S_IDLE;
        endcase
    end

    always_ff @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= state_n;
    end

    // Requests are synchronized into each clock domain and consumed on the
    // falling edge, so changing a gate cannot truncate a high clock pulse.
    always_ff @(posedge clk0 or negedge rst_n) begin
        if (!rst_n) begin req0_c1 <= 1'b0; req0_c2 <= 1'b0; end
        else begin req0_c1 <= req0; req0_c2 <= req0_c1; end
    end
    always_ff @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) begin req1_c1 <= 1'b0; req1_c2 <= 1'b0; end
        else begin req1_c1 <= req1; req1_c2 <= req1_c1; end
    end
    always_ff @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) en0 <= 1'b0;
        else        en0 <= req0_c2;
    end
    always_ff @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) en1 <= 1'b0;
        else        en1 <= req1_c2;
    end

    assign clk_out = (clk0 & en0) | (clk1 & en1);
endmodule
