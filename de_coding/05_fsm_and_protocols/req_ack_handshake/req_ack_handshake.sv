module handshake_master (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] data,
    input  logic       ack,

    output logic       req,
    output logic [7:0] data_out,
    output logic       done
);

    typedef enum logic {
        IDLE,
        WAIT_ACK
    } state_t;

    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin
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
