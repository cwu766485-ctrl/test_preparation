module async_fifo #(
    parameter int W = 8,
    parameter int D = 16
) (
    input  logic         wclk,
    input  logic         rclk,
    input  logic         rst_n,
    input  logic         w_en,
    input  logic         r_en,
    input  logic [W-1:0] wdata,
    output logic [W-1:0] rdata,
    output logic         full,
    output logic         empty
);

    localparam int AW = $clog2(D);

    logic [W-1:0] mem [0:D-1];
    logic [AW:0]  wptr_bin, rptr_bin;
    logic [AW:0]  wptr_gray, rptr_gray;
    logic [AW:0]  rptr_gray_w1, rptr_gray_w2;
    logic [AW:0]  wptr_gray_r1, wptr_gray_r2;

    always_ff @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
        end
        else if (w_en && !full) begin
            mem[wptr_bin[AW-1:0]] <= wdata;
            wptr_bin               <= wptr_bin + 1'b1;
            wptr_gray              <= (wptr_bin + 1'b1) ^
                                       ((wptr_bin + 1'b1) >> 1);
        end
    end

    always_ff @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
            rdata     <= '0;
        end
        else if (r_en && !empty) begin
            rdata     <= mem[rptr_bin[AW-1:0]];
            rptr_bin  <= rptr_bin + 1'b1;
            rptr_gray <= (rptr_bin + 1'b1) ^
                         ((rptr_bin + 1'b1) >> 1);
        end
    end

    always_ff @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_gray_w1 <= '0;
            rptr_gray_w2 <= '0;
        end
        else begin
            rptr_gray_w1 <= rptr_gray;
            rptr_gray_w2 <= rptr_gray_w1;
        end
    end

    always_ff @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_gray_r1 <= '0;
            wptr_gray_r2 <= '0;
        end
        else begin
            wptr_gray_r1 <= wptr_gray;
            wptr_gray_r2 <= wptr_gray_r1;
        end
    end

    assign empty = (rptr_gray == wptr_gray_r2);
    assign full  = (wptr_gray == {~rptr_gray_w2[AW:AW-1],
                                  rptr_gray_w2[AW-2:0]});

endmodule
