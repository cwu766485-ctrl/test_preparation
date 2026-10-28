`timescale 1ns/1ps

// NM6008 Mock Test 3: sequential unsigned 2x2 matrix multiplier.
// A_flat = {a00, a01, a10, a11}; B_flat = {b00, b01, b10, b11}.
// Exactly ONE 8x8 multiplication operator and ONE 17-bit adder.
// busy itself encodes the IDLE/RUN FSM state.
// A rising edge accepting start is cycle 0; cycles 1..8 execute products.
// At the cycle-8 rising edge, C values are final, busy=0 and done=1.
// done is a one-cycle pulse. start is ignored while busy.
// Only C outputs are updated sequentially; partial outputs may be visible.
module matrix_mul_2x2 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] A_flat,
    input  wire [31:0] B_flat,
    output reg  [16:0] C00,
    output reg  [16:0] C01,
    output reg  [16:0] C10,
    output reg  [16:0] C11,
    output reg         busy,
    output reg         done
);
    reg [31:0] a_hold;
    reg [31:0] b_hold;
    reg [2:0]  step;

    reg [7:0]  mul_a;
    reg [7:0]  mul_b;
    reg [16:0] acc_in;

    // Shared datapath: synthesize exactly one '*' and one '+' operator.
    wire [15:0] product;
    wire [16:0] acc_result;
    assign product    = mul_a * mul_b;
    assign acc_result = acc_in + {1'b0, product};

    // 0,1 => C00; 2,3 => C01; 4,5 => C10; 6,7 => C11.
    // Input registers are the sole sources during busy.
    always @(*) begin
        mul_a  = 8'd0;
        mul_b  = 8'd0;
        acc_in = 17'd0;
        case (step)
            3'd0: begin
                mul_a = a_hold[31:24]; // a00
                mul_b = b_hold[31:24]; // b00
                acc_in = C00;
            end
            3'd1: begin
                mul_a = a_hold[23:16]; // a01
                mul_b = b_hold[15:8];  // b10
                acc_in = C00;
            end
            3'd2: begin
                mul_a = a_hold[31:24]; // a00
                mul_b = b_hold[23:16]; // b01
                acc_in = C01;
            end
            3'd3: begin
                mul_a = a_hold[23:16]; // a01
                mul_b = b_hold[7:0];   // b11
                acc_in = C01;
            end
            3'd4: begin
                mul_a = a_hold[15:8];  // a10
                mul_b = b_hold[31:24]; // b00
                acc_in = C10;
            end
            3'd5: begin
                mul_a = a_hold[7:0];   // a11
                mul_b = b_hold[15:8];  // b10
                acc_in = C10;
            end
            3'd6: begin
                mul_a = a_hold[15:8];  // a10
                mul_b = b_hold[23:16]; // b01
                acc_in = C11;
            end
            3'd7: begin
                mul_a = a_hold[7:0];   // a11
                mul_b = b_hold[7:0];   // b11
                acc_in = C11;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_hold <= 32'd0;
            b_hold <= 32'd0;
            step   <= 3'd0;
            C00    <= 17'd0;
            C01    <= 17'd0;
            C10    <= 17'd0;
            C11    <= 17'd0;
            busy   <= 1'b0;
            done   <= 1'b0;
        end else begin
            done <= 1'b0; // one clock only
            if (!busy) begin
                if (start) begin
                    a_hold <= A_flat;
                    b_hold <= B_flat;
                    step   <= 3'd0;
                    C00    <= 17'd0;
                    C01    <= 17'd0;
                    C10    <= 17'd0;
                    C11    <= 17'd0;
                    busy   <= 1'b1;
                end
            end else begin
                // Four destinations, but all updates use the one acc_result.
                case (step)
                    3'd0, 3'd1: C00 <= acc_result;
                    3'd2, 3'd3: C01 <= acc_result;
                    3'd4, 3'd5: C10 <= acc_result;
                    3'd6, 3'd7: C11 <= acc_result;
                endcase

                if (step == 3'd7) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    step <= 3'd0;
                end else begin
                    step <= step + 3'd1;
                end
            end
        end
    end
endmodule
