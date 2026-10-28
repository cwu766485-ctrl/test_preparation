

module sync_fifo #(
    parameter integer W = 8,
    parameter integer D = 16
) (
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [W-1:0] wdata,
    output reg [W-1:0] rdata,
    output wire full,
    output wire empty
);

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    localparam integer AW = $clog2(D);
    reg [W-1:0] mem [0:D-1];
    reg [AW:0] wptr;
    reg [AW:0] rptr;

    assign empty = (wptr == rptr);
    assign full  = (wptr[AW] != rptr[AW]) &&
                   (wptr[AW-1:0] == rptr[AW-1:0]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr  <= 0;
            rptr  <= 0;
            rdata <= 0;
        end
        else begin
            if (wr_en && !full) begin
                mem[wptr[AW-1:0]] <= wdata;
                wptr               <= wptr + 1'b1;
            end

            if (rd_en && !empty) begin
                rdata <= mem[rptr[AW-1:0]];
                rptr  <= rptr + 1'b1;
            end
        end
    end

endmodule