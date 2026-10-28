module sync_fifo #(
    parameter int W = 8,
    parameter int D = 16
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         wr_en,
    input  logic         rd_en,
    input  logic [W-1:0] wdata,
    output logic [W-1:0] rdata,
    output logic         full,
    output logic         empty
);

    initial begin
        assert (W > 0 && D >= 2 && ((D & (D-1)) == 0))
        else $fatal(1, "Invalid FIFO parameters");
    end

    localparam int AW = $clog2(D);
    logic [W-1:0] mem [0:D-1];
    logic [AW:0]  wptr;
    logic [AW:0]  rptr;

    assign empty = (wptr == rptr);
    assign full  = (wptr[AW] != rptr[AW]) &&
                   (wptr[AW-1:0] == rptr[AW-1:0]);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr  <= '0;
            rptr  <= '0;
            rdata <= '0;
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
