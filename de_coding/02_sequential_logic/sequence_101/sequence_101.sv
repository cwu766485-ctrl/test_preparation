module seq_detect_101 (
    input  logic clk,
    input  logic rst_n,
    input  logic data,
    output logic flag
);

    typedef enum logic [1:0] {
        IDLE,
        GOT_1,
        GOT_10
    } state_t;

    state_t state;
    state_t next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        flag       = 1'b0;

        case (state)
            IDLE: begin
                next_state = data ? GOT_1 : IDLE;
            end
            GOT_1: begin
                next_state = data ? GOT_1 : GOT_10;
            end
            GOT_10: begin
                if (data) begin
                    next_state = GOT_1;
                    flag       = 1'b1;
                end
                else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
