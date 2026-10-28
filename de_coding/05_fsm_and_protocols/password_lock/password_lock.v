// Unlock after the key sequence 1, 3, 5, 7. Three incorrect keys latch alarm.
module password_lock (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       key_valid,
    input  wire [3:0] key_data,
    output reg        unlock,
    output reg        alarm
);
    localparam [1:0] S0 = 2'b00,
                     S1 = 2'b01,
                     S2 = 2'b10,
                     S3 = 2'b11;

    reg [1:0] state;
    reg [1:0] fail_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S0;
            fail_cnt <= 2'd0;
            unlock   <= 1'b0;
            alarm    <= 1'b0;
        end
        else begin
            unlock <= 1'b0;
            if (!alarm && key_valid) begin
                case (state)
                    S0: begin
                        if (key_data == 4'h1) begin
                            state    <= S1;
                            fail_cnt <= 2'd0;
                        end
                        else if (fail_cnt == 2'd2) begin
                            alarm <= 1'b1;
                        end
                        else begin
                            state    <= S0;
                            fail_cnt <= fail_cnt + 1'b1;
                        end
                    end
                    S1: begin
                        if (key_data == 4'h3) begin
                            state    <= S2;
                            fail_cnt <= 2'd0;
                        end
                        else if (fail_cnt == 2'd2) begin
                            state <= S0;
                            alarm <= 1'b1;
                        end
                        else begin
                            state    <= S0;
                            fail_cnt <= fail_cnt + 1'b1;
                        end
                    end
                    S2: begin
                        if (key_data == 4'h5) begin
                            state    <= S3;
                            fail_cnt <= 2'd0;
                        end
                        else if (fail_cnt == 2'd2) begin
                            state <= S0;
                            alarm <= 1'b1;
                        end
                        else begin
                            state    <= S0;
                            fail_cnt <= fail_cnt + 1'b1;
                        end
                    end
                    S3: begin
                        if (key_data == 4'h7) begin
                            state    <= S0;
                            fail_cnt <= 2'd0;
                            unlock   <= 1'b1;
                        end
                        else if (fail_cnt == 2'd2) begin
                            state <= S0;
                            alarm <= 1'b1;
                        end
                        else begin
                            state    <= S0;
                            fail_cnt <= fail_cnt + 1'b1;
                        end
                    end
                    default: begin
                        state    <= S0;
                        fail_cnt <= 2'd0;
                    end
                endcase
            end
        end
    end
endmodule
