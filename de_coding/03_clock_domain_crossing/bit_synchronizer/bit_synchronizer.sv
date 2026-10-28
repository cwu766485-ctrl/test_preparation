// fast clk to slow clk
// Persistent one-bit LEVEL only. Short pulses need an event CDC instead.
module bit_sync2 #(
    parameter int STAGES = 2
) (
    input  logic dst_clk,
    input  logic rst_n, // destination reset: async assert, sync release
    input  logic async_i, //belong to other clock domain.
    output logic sync_o
);
/*
这里使用两级触发器：
async_i --> meta --> sync_o
             |
          可能亚稳
- meta：第一级同步触发器，允许它承担亚稳态风险
- sync_o：第二级触发器，通常作为目标域正式使用的信号
*/
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    logic [STAGES-1:0] sync_pipe;

    initial begin
        assert (STAGES >= 2) else $fatal(1, "bit_sync2: STAGES must be >= 2");
    end

    always_ff @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_pipe <= '0;
        end
        else begin
            sync_pipe <= {sync_pipe[STAGES-2:0], async_i};
        end
    end

    assign sync_o = sync_pipe[STAGES-1];

    // Choose STAGES from library MTBF data, dst_clk frequency, input toggle
    // rate and required lifetime. Keep stages close; fan out only from sync_o.

endmodule

/*
适用条件
适合：
- enable
- mode
- interrupt level
- busy
- error
- 状态标志
- 慢变化的单 bit 电平
不适合：
- 窄脉冲
- 高频事件
- 多 bit 总线
- 需要每次变化都被捕获的信号
*/
