

module crc8 (
    input wire clk,
    input wire rst_n,
    input wire data_in,
    input wire data_valid,
    output reg [7:0] crc,
    output reg crc_valid
);

    reg [2:0] bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc       <= 8'h00;
            bit_count <= 3'd0;
            crc_valid <= 1'b0;
        end
        else begin
            crc_valid <= 1'b0;

            if (data_valid) begin
                if (crc[7] ^ data_in) begin
                    crc <= {crc[6:0], 1'b0} ^ 8'h07;
                end
                else begin
                    crc <= {crc[6:0], 1'b0};
                end

                if (bit_count == 3'd7) begin
                    bit_count <= 3'd0;
                    crc_valid <= 1'b1;
                end
                else begin
                    bit_count <= bit_count + 1'b1;
                end
            end
        end
    end

endmodule