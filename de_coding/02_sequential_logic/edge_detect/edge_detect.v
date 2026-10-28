

module edge_detect (
    input wire clk,
    input wire rst_n,
    input wire data,
    output wire pos_edge,
    output wire neg_edge,
    output wire data_edge
);
    reg d0, d1;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            d0   <= 1'b0;
            d1   <= 1'b0;
        end
        else begin
            d0 <= data;
            d1 <= d0;
        end
    end

    assign pos_edge = d0 & ~d1;
    assign neg_edge = ~d0 & d1;
    assign data_edge = pos_edge | neg_edge;
endmodule