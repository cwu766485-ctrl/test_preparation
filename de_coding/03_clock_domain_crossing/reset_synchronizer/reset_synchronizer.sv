// Asynchronous assertion, synchronous deassertion reset synchronizer.
// Instantiate one reset_synchronizer for every independent clock domain.
module reset_synchronizer #(
    parameter int STAGES = 2
) (
    input  logic clk,
    input  logic async_rst_n,
    output logic sync_rst_n
);

    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    logic [STAGES-1:0] sync_pipe;

    initial begin
        assert (STAGES >= 2)
            else $fatal(1, "reset_synchronizer: STAGES must be >= 2");
    end

    always_ff @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            sync_pipe <= '0;
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
