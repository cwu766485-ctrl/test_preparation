// fast clk to slow clk
// Persistent one-bit LEVEL only. Short pulses need an event CDC instead.


module bit_sync2 #(
    parameter integer STAGES = 2
) (
    input wire dst_clk,
    input wire rst_n, // destination reset: async assert, sync release
    input wire async_i, //belong to other clock domain.
    output wire sync_o
);
/*
这里使用两级触发器：
async_i = async_i - 1> meta = meta - 1> sync_o
             |
          可能亚稳
- meta：第一级同步触发器，允许它承担亚稳态风险
- sync_o：第二级触发器，通常作为目标域正式使用的信号
*/
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [STAGES-1:0] sync_pipe;

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_pipe <= 0;
        end
        else begin
            sync_pipe <= {sync_pipe[STAGES-2:0], async_i};
        end
    end

    assign sync_o = sync_pipe[STAGES-1];

    // Choose STAGES from library MTBF data, dst_clk frequency, input toggle
    // rate and required lifetime. Keep stages close; fan out only from sync_o.

endmodule