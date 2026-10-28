`timescale 1ns/1ps

module debounce #(
    parameter int CNT_MAX = 1_000_000
) (
    input  logic clk,
    input  logic rst_n,
    input  logic btn_in, // asynchronous button signal
    output logic btn_out // debounced level
);

    // Count from 0 through CNT_MAX-1; keep at least one bit for CNT_MAX=1.
    localparam int CNT_W = (CNT_MAX > 1) ? $clog2(CNT_MAX + 1) : 1;

    (* ASYNC_REG = "TRUE" *) logic btn_sync_ff1;
    (* ASYNC_REG = "TRUE" *) logic btn_sync_ff2;
    logic btn_sample;
    logic [CNT_W-1:0] count;

`ifndef SYNTHESIS
    initial begin : check_parameters
        if (CNT_MAX < 1) begin
            $fatal(1, "debounce: CNT_MAX must be >= 1 (got %0d)", CNT_MAX);
        end
    end
`endif

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync_ff1 <= 1'b0;
            btn_sync_ff2 <= 1'b0;
            btn_sample   <= 1'b0;
            btn_out      <= 1'b0;
            count        <= '0;
        end
        else begin
            // Synchronize the asynchronous input before debounce logic.
            btn_sync_ff1 <= btn_in;
            btn_sync_ff2 <= btn_sync_ff1;

            if (btn_sync_ff2 != btn_sample) begin
                // A new candidate level starts a fresh stability interval.
                btn_sample <= btn_sync_ff2;
                count      <= '0;
            end
            else if (count < CNT_MAX - 1) begin
                count <= count + 1'b1;
            end
            else begin
                // Saturate the counter and update only after CNT_MAX stable clocks.
                btn_out <= btn_sample;
            end
        end
    end

endmodule
