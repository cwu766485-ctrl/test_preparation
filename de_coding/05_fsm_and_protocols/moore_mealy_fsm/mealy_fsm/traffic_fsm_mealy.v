module traffic_fsm_mealy (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    output reg  [1:0] out
);


    localparam [1:0]
        IDLE = 2'b00,
        RUN  = 2'b01,
        DONE = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // 2. Next-state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: if (start)
                      next_state = RUN;

            RUN:  next_state = DONE;
            DONE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    // 3. Mealy output logic
    always @(*) begin
        out = 2'b00;

        if (!rst_n) begin
            out = 2'b00;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start)
                        out = 2'b01;
                    else
                        out = 2'b00;
                end

                RUN:  out = 2'b01;
                DONE: out = 2'b10;

                default: out = 2'b00;
            endcase
        end
    end
    
endmodule
