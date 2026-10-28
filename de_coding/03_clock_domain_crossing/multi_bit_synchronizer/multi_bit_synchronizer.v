// Bundled-data four-phase handshake for occasional multi-bit transfers.
/*
① req=0, ack=0   空闲，可以接收源数据
② req=1, ack=0   源域已锁存数据并发出请求
③ req=1, ack=1   目标域已取样数据并应答
④ req=0, ack=1   源域撤销请求
回到 req=0, ack=0；才允许下一笔
*/


module multi_bit_synchronizer #(
    parameter integer W = 8
) (
    input wire src_clk,
    input wire dst_clk,
    input wire rst_n,
    input wire src_valid,
    input wire [W-1:0] src_data,
    output wire src_ready,
    output reg dst_valid,
    output reg [W-1:0] dst_data
);

    reg req_src;
    reg ack_dst;
    reg ack_sync_1;
    reg ack_sync_2;
    reg req_sync_1;
    reg req_sync_2;
    reg [W-1:0] data_hold;

    // Simulation-only parameter assertion omitted in the Verilog-2005 translation.

    always @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            req_src   <= 1'b0;
            data_hold <= 0;
        end
        else begin
            if (src_valid && src_ready) begin
                req_src   <= 1'b1;
                data_hold <= src_data;
            end
            else if (req_src && ack_sync_2)
                req_src <= 1'b0;
        end
    end

    always @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            ack_sync_1 <= 1'b0;
            ack_sync_2 <= 1'b0;
        end
        else begin
            ack_sync_1 <= ack_dst;
            ack_sync_2 <= ack_sync_1;
        end
    end

    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            req_sync_1 <= 1'b0;
            req_sync_2 <= 1'b0;
            ack_dst    <= 1'b0;
            dst_valid  <= 1'b0;
            dst_data   <= 0;
        end
        else begin
            req_sync_1 <= req_src;
            req_sync_2 <= req_sync_1;
            dst_valid  <= 1'b0;

            // Four-phase handshake: accept only the asserted request.
            if (req_sync_2 && !ack_dst) begin
                dst_data <= data_hold;
                dst_valid <= 1'b1;
                ack_dst  <= 1'b1;
            end
            else if (!req_sync_2 && ack_dst)
                ack_dst <= 1'b0;
        end
    end

    // Wait for ack to return LOW before accepting another word.
    assign src_ready = rst_n && !req_src && !ack_sync_2;

    // data_hold is a bundled-data path. It stays fixed until ack returns;
    // constrain its arrival relative to the synchronized request. Both clock
    // domains must share a coherent reset episode. There is no dst_ready:
    // the receiver must consume dst_data when dst_valid pulses, or add a
    // destination backpressure/ack protocol.

endmodule