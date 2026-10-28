

module serial_to_parallel #(
    parameter integer W = 8
) (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire msb_first,
    input wire serial_i,
    output reg [W-1:0] parallel_o,
    output reg valid
);

    localparam integer CW = $clog2(W + 1);
    reg [CW-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_o <= 0;
            count      <= 0;
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
                    count <= 0;
                    valid <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule