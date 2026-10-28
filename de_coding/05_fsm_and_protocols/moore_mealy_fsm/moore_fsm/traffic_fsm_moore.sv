module traffic_fsm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    output logic [1:0] out
);

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE
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

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = RUN;
                end
            end
            RUN: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_comb begin
        case (state)
            IDLE:    out = 2'b00;
            RUN:     out = 2'b01;
            DONE:    out = 2'b10;
            default: out = 2'b00;
        endcase
    end

endmodule
