

module uart_rx #(
    parameter integer BAUD_CNT = 16
) (
    input wire clk,
    input wire rst_n,
    input wire rx,
    output reg [7:0] data_out,
    output reg data_valid
);

        localparam [1:0] IDLE = 0;
    localparam [1:0] START = (0) + 1'b1;
    localparam [1:0] DATA = ((0) + 1'b1) + 1'b1;
    localparam [1:0] STOP = (((0) + 1'b1) + 1'b1) + 1'b1;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.

    reg [1:0]       state;
    reg [15:0] baud_count;
    reg [3:0] bit_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            baud_count <= 0;
            bit_count  <= 0;
            data_out   <= 0;
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    if (!rx) begin
                        state      <= START;
                        baud_count <= 0;
                    end
                end

                START: begin
                    if (baud_count == BAUD_CNT / 2 - 1) begin
                        baud_count <= 0;
                        bit_count  <= 0;
                        state      <= DATA;
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_count == BAUD_CNT - 1) begin
                        baud_count       <= 0;
                        data_out[bit_count] <= rx;

                        if (bit_count == 7) begin
                            bit_count <= 0;
                            state     <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                STOP: begin
                    if (baud_count == BAUD_CNT - 1) begin
                        baud_count <= 0;
                        data_valid <= 1'b1;
                        state      <= IDLE;
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule