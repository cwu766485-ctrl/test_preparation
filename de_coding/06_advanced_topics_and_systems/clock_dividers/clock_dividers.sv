module clk_div_odd #(
    parameter int N = 5
) (
    input  logic clk,
    input  logic rst_n,
    output logic clk_out
);

    localparam int CNT_W = (N <= 2) ? 1 : $clog2(N);

    logic [CNT_W-1:0] count;
    logic              pos_phase;
    logic              neg_phase;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count     <= '0;
            pos_phase <= 1'b0;
        end
        else begin
            if (count == N - 1) begin
                count <= '0;
            end
            else begin
                count <= count + 1'b1;
            end

            pos_phase <= (count < (N + 1) / 2);
        end
    end

    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            neg_phase <= 1'b0;
        end
        else begin
            neg_phase <= (count < (N + 1) / 2);
        end
    end

    assign clk_out = pos_phase | neg_phase;

endmodule
