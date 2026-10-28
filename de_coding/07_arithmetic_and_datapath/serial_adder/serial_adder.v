// Variable-width unsigned serial adder. Operands load in parallel, then one
// least-significant bit is added per cycle. SUM includes the final carry.
module serial_adder #(
    parameter integer WIDTH = 8,
    parameter integer COUNT_WIDTH = (WIDTH <= 1) ? 1 : $clog2(WIDTH)
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,
    input  wire [WIDTH-1:0]     a,
    input  wire [WIDTH-1:0]     b,
    output reg  [WIDTH:0]       sum,
    output reg                  busy,
    output reg                  done
);
    reg [WIDTH-1:0] a_shift, b_shift;
    reg carry;
    reg [COUNT_WIDTH-1:0] bit_index;
    wire bit_sum = a_shift[0] ^ b_shift[0] ^ carry;
    wire carry_next = (a_shift[0] & b_shift[0]) |
                      (a_shift[0] & carry) | (b_shift[0] & carry);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_shift <= 0; b_shift <= 0; carry <= 0; bit_index <= 0;
            sum <= 0; busy <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy && start) begin
                a_shift <= a; b_shift <= b; carry <= 1'b0;
                sum <= 0; bit_index <= 0; busy <= 1'b1;
            end else if (busy) begin
                sum[bit_index] <= bit_sum;
                carry <= carry_next;
                a_shift <= a_shift >> 1;
                b_shift <= b_shift >> 1;
                if (bit_index == WIDTH-1) begin
                    sum[WIDTH] <= carry_next;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    bit_index <= bit_index + 1'b1;
                end
            end
        end
    end
endmodule
