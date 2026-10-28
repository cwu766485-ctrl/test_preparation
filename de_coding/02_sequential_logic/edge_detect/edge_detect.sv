module edge_detect (
    input  logic clk,
    input  logic rst_n,
    input  logic data,
    output logic pos_edge,
    output logic neg_edge,
    output logic data_edge
);
    logic d0, d1;

    always_ff @(posedge clk or negedge rst_n) begin
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
