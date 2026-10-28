

module async_fifo #(
    parameter integer W = 8,
    parameter integer D = 16
) (
    input wire wclk,
    input wire rclk,
    input wire rst_n,
    input wire w_en,
    input wire r_en,
    input wire [W-1:0] wdata,
    output reg [W-1:0] rdata,
    output wire full,
    output wire empty
);

    localparam integer AW = $clog2(D);

    reg [W-1:0] mem [0:D-1];
    reg [AW:0] wptr_bin, rptr_bin;
    reg [AW:0] wptr_gray, rptr_gray;
    reg [AW:0] rptr_gray_w1, rptr_gray_w2;
    reg [AW:0] wptr_gray_r1, wptr_gray_r2;

    always @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_bin  <= 0;
            wptr_gray <= 0;
        end
        else if (w_en && !full) begin
            mem[wptr_bin[AW-1:0]] <= wdata;
            wptr_bin               <= wptr_bin + 1'b1;
            wptr_gray              <= (wptr_bin + 1'b1) ^
                                       ((wptr_bin + 1'b1) >> 1);
        end
    end

    always @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_bin  <= 0;
            rptr_gray <= 0;
            rdata     <= 0;
        end
        else if (r_en && !empty) begin
            rdata     <= mem[rptr_bin[AW-1:0]];
            rptr_bin  <= rptr_bin + 1'b1;
            rptr_gray <= (rptr_bin + 1'b1) ^
                         ((rptr_bin + 1'b1) >> 1);
        end
    end

    always @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_gray_w1 <= 0;
            rptr_gray_w2 <= 0;
        end
        else begin
            rptr_gray_w1 <= rptr_gray;
            rptr_gray_w2 <= rptr_gray_w1;
        end
    end

    always @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_gray_r1 <= 0;
            wptr_gray_r2 <= 0;
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