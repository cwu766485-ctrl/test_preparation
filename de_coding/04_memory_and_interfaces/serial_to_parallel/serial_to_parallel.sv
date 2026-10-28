module serial_to_parallel #(
    parameter int W = 8
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         en,
    input  logic         msb_first,
    input  logic         serial_i,
    output logic [W-1:0] parallel_o,
    output logic         valid
);

    localparam int CW = $clog2(W + 1);
    logic [CW-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_o <= '0;
            count      <= '0;
            valid      <= 1'b0;
        end
        else begin
            valid <= 1'b0;

            if (en) begin
                if (msb_first) begin
                    parallel_o <= {parallel_o[W-2:0], serial_i};
                end
                else begin
                    parallel_o <= {serial_i, parallel_o[W-1:1]};
                end

                if (count == W - 1) begin
                    count <= '0;
                    valid <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule
