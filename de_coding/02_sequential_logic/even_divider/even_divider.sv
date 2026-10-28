module clk_div_even #(
    parameter int N = 10
) (
    input  logic clk,
    input  logic rst_n,
    output logic clk_div
);

    localparam int CNT_W = (N <= 2) ? 1 : $clog2(N);
    logic [CNT_W-1:0] cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= '0;
            clk_div <= 1'b0;
        end
        else if (cnt == N / 2 - 1) begin
            cnt     <= '0;
            clk_div <= ~clk_div;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end

endmodule
