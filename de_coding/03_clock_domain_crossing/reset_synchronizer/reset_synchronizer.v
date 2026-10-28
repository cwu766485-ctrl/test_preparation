// Asynchronous assertion, synchronous deassertion reset synchronizer.
// Instantiate one reset_synchronizer for every independent clock domain.


module reset_synchronizer #(
    parameter integer STAGES = 2
) (
    input wire clk,
    input wire async_rst_n,
    output wire sync_rst_n
);

    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [STAGES-1:0] sync_pipe;

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    always @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            sync_pipe <= 0;
        end
        else begin
            sync_pipe <= {sync_pipe[STAGES-2:0], 1'b1};
        end
    end

    assign sync_rst_n = sync_pipe[STAGES-1];

    // Release takes STAGES rising edges after async_rst_n rises. If clk is
    // stopped, release waits. Assertion requires the minimum reset pulse
    // width specified by the target flip-flop library.

endmodule