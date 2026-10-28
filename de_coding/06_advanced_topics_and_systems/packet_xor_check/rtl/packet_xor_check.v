`timescale 1ns/1ps
// Mock7: valid/start/last framed stream; XOR checksum and saturating length.
// Only valid & start starts a packet. A new start aborts any incomplete packet.
// Zero-cycle gaps are allowed. A 1-beat packet has start=last=1.
// count saturates at MAX_LEN+1, overflow indicates a too-long packet.
module packet_xor_check #(
    parameter integer MAX_LEN = 8
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       in_valid,
    input  wire       in_start,
    input  wire       in_last,
    input  wire [7:0] in_data,
    output reg        packet_done,
    output reg [7:0]  checksum,
    output reg [7:0]  length,
    output reg        overflow
);
    reg        active;
    reg [7:0]  running_xor;
    reg [7:0]  count;
    wire [7:0] next_xor = running_xor ^ in_data;
    wire [7:0] next_count = (count < MAX_LEN+1) ? count+8'd1 : count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            active <= 0; running_xor <= 0; count <= 0;
            packet_done <= 0; checksum <= 0; length <= 0; overflow <= 0;
        end else begin
            packet_done <= 0;
            if (in_valid) begin
                if (in_start) begin
                    running_xor <= in_data;
                    count <= 8'd1;
                    active <= !in_last;
                    if (in_last) begin
                        packet_done <= 1;
                        checksum <= in_data;
                        length <= 1;
                        overflow <= (MAX_LEN < 1);
                    end
                end else if (active) begin
                    running_xor <= next_xor;
                    count <= next_count;
                    if (in_last) begin
                        packet_done <= 1;
                        checksum <= next_xor;
                        length <= next_count;
                        overflow <= (next_count > MAX_LEN);
                        active <= 0;
                    end
                end
            end
        end
    end
endmodule
