// Educational glitch-free clock mux: disable the active clock on its falling
// edge before enabling the other. A switch can pause clk_out for several
// cycles. Both input clocks MUST keep running; use a library clock mux cell
// for production clock trees and follow its STA/CTS constraints.


module glitch_free_clock_switch (
    input wire clk0,
    input wire clk1,
    input wire sel_async,
    input wire rst_n,
    output wire clk_out
);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [1:0] sel0_sync;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [1:0] sel1_sync;
    reg en0, en1;

    always @(posedge clk0 or negedge rst_n) begin
        if (!rst_n) sel0_sync <= 0;
        else        sel0_sync <= {sel0_sync[0], sel_async};
    end
    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) sel1_sync <= 0;
        else        sel1_sync <= {sel1_sync[0], sel_async};
    end

    always @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) en0 <= 1'b0;
        else        en0 <= !sel0_sync[1] && !en1;
    end
    always @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) en1 <= 1'b0;
        else        en1 <= sel1_sync[1] && !en0;
    end

    assign clk_out = (clk0 && en0) || (clk1 && en1);
    // en0/en1 must be implemented as clock-gating safe reg. Generic RTL
    // synthesis alone does not certify a glitch-free physical clock tree.
endmodule

module glitch_free_clock_switch_ownership (
    input wire ctrl_clk,
    input wire clk0,
    input wire clk1,
    input wire sel_async,
    input wire rst_n,
    output wire clk_out
);
    localparam [2:0] S_IDLE = 0;
    localparam [2:0] S_RUN0 = (0) + 1'b1;
    localparam [2:0] S_RUN1 = ((0) + 1'b1) + 1'b1;
    localparam [2:0] S_WAIT_OFF0 = (((0) + 1'b1) + 1'b1) + 1'b1;
    localparam [2:0] S_WAIT_OFF1 = ((((0) + 1'b1) + 1'b1) + 1'b1) + 1'b1;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.
    reg [2:0] state, state_n;
    reg sel_c1, sel_c2;
    reg req0, req1;
    reg req0_c1, req0_c2, req1_c1, req1_c2;
    reg en0, en1;
    reg en0_c1, en0_c2, en1_c1, en1_c2;

    // Selection enters the always-running controller domain.
    (* ASYNC_REG = "TRUE" *) reg sel_meta;
    always @(posedge ctrl_clk or negedge rst_n) begin
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
    always @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n) begin
            en0_c1 <= 1'b0; en0_c2 <= 1'b0;
            en1_c1 <= 1'b0; en1_c2 <= 1'b0;
        end else begin
            en0_c1 <= en0; en0_c2 <= en0_c1;
            en1_c1 <= en1; en1_c2 <= en1_c1;
        end
    end

    always @* begin
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

    always @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= state_n;
    end

    // Requests are synchronized into each clock domain and consumed on the
    // falling edge, so changing a gate cannot truncate a high clock pulse.
    always @(posedge clk0 or negedge rst_n) begin
        if (!rst_n) begin req0_c1 <= 1'b0; req0_c2 <= 1'b0; end
        else begin req0_c1 <= req0; req0_c2 <= req0_c1; end
    end
    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n) begin req1_c1 <= 1'b0; req1_c2 <= 1'b0; end
        else begin req1_c1 <= req1; req1_c2 <= req1_c1; end
    end
    always @(negedge clk0 or negedge rst_n) begin
        if (!rst_n) en0 <= 1'b0;
        else        en0 <= req0_c2;
    end
    always @(negedge clk1 or negedge rst_n) begin
        if (!rst_n) en1 <= 1'b0;
        else        en1 <= req1_c2;
    end

    assign clk_out = (clk0 & en0) | (clk1 & en1);
endmodule
