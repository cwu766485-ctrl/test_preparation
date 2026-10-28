`timescale 1ns/1ps
// Mock4: unsigned 8x8 shift-and-add multiplier, one 16-bit adder reused.
// Contract: start accepted only when !busy; exactly 8 busy cycles thereafter.
// done pulses on the eighth calculation edge. Outputs hold between transactions.
module seq_multiplier8 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg  [15:0] product,
    output reg         busy,
    output reg         done
);
    reg [15:0] partial_sum;
    reg [15:0] shifted_a;
    reg [7:0]  shifted_b;
    reg [3:0]  iteration;
    wire [15:0] next_sum = partial_sum + (shifted_b[0] ? shifted_a : 16'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product     <= 16'd0;
            partial_sum <= 16'd0;
            shifted_a   <= 16'd0;
            shifted_b   <= 8'd0;
            iteration   <= 4'd0;
            busy        <= 1'b0;
            done        <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    partial_sum <= 16'd0;
                    shifted_a   <= {8'd0, a};
                    shifted_b   <= b;
                    iteration   <= 4'd0;
                    busy        <= 1'b1;
                end
            end else begin
                partial_sum <= next_sum;
                shifted_a   <= shifted_a << 1;
                shifted_b   <= shifted_b >> 1;
                iteration   <= iteration + 4'd1;
                if (iteration == 4'd7) begin
                    product <= next_sum;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                end
            end
        end
    end
endmodule
