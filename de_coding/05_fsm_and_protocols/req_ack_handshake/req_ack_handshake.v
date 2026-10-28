

module handshake_master (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [7:0] data,
    input wire ack,

    output reg req,
    output reg [7:0] data_out,
    output reg done
);

        localparam [0:0] IDLE = 0;
    localparam [0:0] WAIT_ACK = (0) + 1'b1;
    // Verilog-2005 enum constants replace the SystemVerilog typedef.

    reg [0:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            req      <= 1'b0;
            done     <= 1'b0;
            data_out <= 8'd0;
        end
        else begin
            done <= 1'b0;  // Default: one-cycle pulse

            case (state)
                IDLE: begin
                    if (start) begin
                        data_out <= data;
                        req      <= 1'b1;
                        state    <= WAIT_ACK;
                    end
                end

                WAIT_ACK: begin
                    if (ack) begin
                        req   <= 1'b0;
                        done  <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                    req   <= 1'b0;
                end
            endcase
        end
    end

endmodule